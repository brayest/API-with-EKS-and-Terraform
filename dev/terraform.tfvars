# General Config
region                  = "us-east-1"
project                 = "brayest"
environment             = "dev"
domain_name             = "dev.brayest.com"
internal_domain_name    = "brayest-dev.int"
ingress_replicaCount    = 1

# AWS
profile = "brayest-dev"

# VPC config
vpc_cidr_block          = "10.12.0.0/16"
azs_count               = 3
number_subnets          = 3
vpc_offset              = 4
single_nat_gateway      = true
one_nat_gateway_per_az  = false

# Database
rds_engine_version = "15.4"
create_db_parameter_group = true
rds_parameter_group_family = "aurora-postgresql15"
rds_instance_cluster_configuration = {
    writer = {
      instance_class      = "db.t4g.medium"
    }    
  }

# EKS node config 
cluster_version            = "1.29"
eks_endpoint_public_access =  true
eks_admins_arns = [
    "arn:aws:iam::123456789012:user/brayest-dev-admin",
  ]
eks_node_groups ={    
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types  = ["t4g.medium"]
      capacity_type   = "ON_DEMAND"
      labels = {
        nodegroup-type = "default"
      }       
    }           
  }
