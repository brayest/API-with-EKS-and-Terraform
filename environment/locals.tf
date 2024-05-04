data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
}

data "aws_route53_zone" "public_domain_hosted_zone" {
  name         = local.domain_name
  private_zone = false
}

locals {
  cloud_account_id = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  project          = var.project
  environment      = var.environment
  domain_name      = var.domain_name
  cluster_name     = "${var.project}-${var.environment}"

  ingress_replicaCount = var.ingress_replicaCount

  profile        = var.profile

  internal_domain_name = var.internal_domain_name
  notifications_email = "brayest3@gmail.com"

  tags             = {
    Project = local.project
    Environment = var.environment
    Terraform = "managed"
  }

  database = {
    master_user_name      = var.rds_user_name
    engine_version        = var.rds_engine_version
    ca_cert_identifier    = var.rds_ca_cert_identifier
    rds_parameter_group_family = var.rds_parameter_group_family
    create_db_parameter_group = var.create_db_parameter_group
    deletion_protection   = var.rds_deletion_protection
    rds_instance_cluster_configuration = var.rds_instance_cluster_configuration
  }

  account_config = {
    project	                        = local.project
    cloud_account_id                = data.aws_caller_identity.current.account_id
    environment                     = var.environment
    cluster_name                    = local.cluster_name
  }

  cidrs             = chunklist(cidrsubnets(var.vpc_cidr_block, [for i in range(var.azs_count * var.number_subnets) : var.vpc_offset]...), var.azs_count)
  public_cidrs      = local.cidrs[0]
  private_cidrs     = local.cidrs[1]     
  data_cidrs        = local.cidrs[2]     

  vpc_config = {
    vpc_name                       = "${var.project}-${var.environment}"
    vpc_availability_zones         = var.azs_count
    vpc_cidr_block                 = var.vpc_cidr_block
    vpc_public_subnet_cidr_blocks  = local.public_cidrs
    vpc_private_subnet_cidr_blocks = local.private_cidrs
    vpc_data_subnet_cidr_blocks    = local.data_cidrs
    single_nat_gateway             = var.single_nat_gateway
    one_nat_gateway_per_az         = var.one_nat_gateway_per_az    
  }

  cluster_config = {
    region                               = local.region
    project                              = local.project
    environment                          = local.environment
    cluster_name                         = local.cluster_name
    cluster_version                      = var.cluster_version
    eks_endpoint_public_access           = var.eks_endpoint_public_access
    eks_node_groups                      = var.eks_node_groups
    eks_admins_arns                      = var.eks_admins_arns
  }
}