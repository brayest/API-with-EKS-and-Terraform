
# EKS cluster
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

data "aws_iam_policy_document" "eks_admin_policy" {
  statement {
    actions = [
      "eks:*"
    ]
    resources = [
      module.eks.cluster_iam_role_arn,
      "${module.eks.cluster_iam_role_arn}/*"
    ]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = ["eks.amazonaws.com"]
    }
    resources = ["*"]    
  }   
}

resource "aws_iam_policy" "eks_admin_policy" {
  name        = "${local.cluster_config.cluster_name}-admin-${random_string.this.id}"
  path        = "/"
  description = "Admin Policy for the ${local.cluster_config.cluster_name} EKS cluster"
  policy = data.aws_iam_policy_document.eks_admin_policy.json
}

module "eks_admin_role" {
  source  = "../modules/iam/iam-assumable-role"

  trusted_role_arns = local.cluster_config.eks_admins_arns

  create_role = true

  role_name         = "${local.cluster_config.cluster_name}-admin-${random_string.this.id}"
  role_requires_mfa = false

  custom_role_policy_arns = [aws_iam_policy.eks_admin_policy.arn]
}

## VPC CNI Role
module "vpc_cni_irsa" {
  source  = "../modules/iam/iam-role-for-service-accounts-eks"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

## EBS CSI Role
module "ebs_csi" {
  source  = "../modules/iam/iam-role-for-service-accounts-eks"

  role_name_prefix      = "EBS-CSI-${local.environment}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "eks" {
  source  = "../modules/eks"

  cluster_name    = local.cluster_config.cluster_name
  cluster_version = local.cluster_config.cluster_version

  vpc_id          = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = local.cluster_config.eks_endpoint_public_access

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }  

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }  

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi.iam_role_arn
    }
  }

  # Managed Node Groups
  eks_managed_node_group_defaults = {
    ami_type  = "AL2_ARM_64"
    disk_size = 25
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]      
  }

  eks_managed_node_groups = merge(
    {
      nginx = {
        min_size     = local.ingress_replicaCount
        max_size     = 6
        desired_size = local.ingress_replicaCount

        instance_types  = ["t3.small"]
        capacity_type   = "ON_DEMAND"
        ami_type = "AL2_x86_64"
        labels = {
          nodegroup-type = "nginx"
        }       
      }                                         
    },
    local.cluster_config.eks_node_groups
  )

  # aws-auth configmap
  manage_aws_auth_configmap = true

  enable_irsa = true

  # AWS Auth (kubernetes_config_map)
  aws_auth_roles = [
    {
      rolearn  = module.eks_admin_role.iam_role_arn
      username = "manager"
      groups   = ["system:masters"]
    }   
  ]

  aws_auth_users = [
    for s in local.cluster_config.eks_admins_arns : 
    {
      userarn  = s
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [data.aws_caller_identity.current.account_id]

  tags = local.tags
}

resource "kubernetes_storage_class" "ebs_storage_class" {
  depends_on = [
    module.eks
  ]

  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_config.vpc_cidr_block]
  security_group_id = module.eks.cluster_security_group_id
}

resource "kubernetes_daemonset" "ssm_installer" {
  metadata {
    name      = "ssm-installer"
    namespace = "kube-system"
    labels = {
      k8s-app = "ssm-installer"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "ssm-installer"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "ssm-installer"
        }
      }

      spec {
        container {
          image = "busybox"
          name  = "sleeper"
          command = ["sh", "-c", "echo I keep things running! && sleep 3600"]
        }
        init_container {
          image = "amazonlinux"
          image_pull_policy = "Always"
          name = "ssm"
          command = ["/bin/bash"]
          args = ["-c","echo '* * * * * root yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm & rm -rf /etc/cron.d/ssmstart' > /etc/cron.d/ssmstart"]
          security_context {
            allow_privilege_escalation = true
          }
          volume_mount {
            mount_path = "/etc/cron.d"
            name = "cronfile"
          }
          termination_message_path = "/dev/termination-log"
        }
        volume {
          name = "cronfile"
          host_path {
            path = "/etc/cron.d"
            type = "Directory"
          }
        }
        dns_policy = "ClusterFirst"
        restart_policy = "Always"
        termination_grace_period_seconds = 30
      }
    }
  }
}

# Cluster Autoscaler
module "cluster_autoscaler" {
  source  = "../modules/cluster_autoscaler"

  cluster_name = local.cluster_config.cluster_name
  eks_oidc_provier = module.eks.cluster_oidc_issuer_url
  cluster_version  = local.cluster_config.cluster_version

  tags = local.tags
}

# Cert Manager
module "cert_manager" {
  source  = "../modules/cert_manager"

  cluster_name = local.cluster_config.cluster_name
  notifications_email = local.notifications_email
  private_domain = local.internal_domain_name
  create_private_issuer = true

  tags = local.tags

  depends_on = [  module.eks ]
}

# Ingress Controller
module "ingress_controller" {
  depends_on = [
    module.cert_manager,
    module.eks
  ]

  source  = "../modules/ingress_controller"

  cluster_name = local.cluster_config.cluster_name
  private_ingress = true
  vpc_link_enabled = false
  replicaCount = local.ingress_replicaCount

  # If private true then subnets must be passed. 
  private_subnets = join("\\,", module.vpc.private_subnets)

  tags = local.tags
}

