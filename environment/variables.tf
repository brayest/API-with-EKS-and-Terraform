variable "region" {
  type    = string
  default = "us-east-1"
}
variable "project" {
  type    = string
  default = "brayest"
}
variable "utility_role_arn" {
  type = string
  default = null
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "profile" {
  type = string 
  default = "brayest_qa"
}
variable "rds_ca_cert_identifier" {
  type = string
  default = "rds-ca-rsa2048-g1"
}

variable "cluster_version" {
  type    = string
  default = "1.22"
}
variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default = false
}

variable "vpc_cidr_block" {
  type = string
  default = "10.100.0.0/16"
}
variable "single_nat_gateway" {
  type = bool
  default = true
}
variable "set_alarms" {
  type = bool
  default = false
}
variable "one_nat_gateway_per_az" {
  type = bool
  default = false
}
variable "azs_count" {
  type = number
  default = 3
}

variable "number_subnets" {
  type = number
  default = 3
  
}

variable vpc_offset {
        description     = "Denotes the number of address locations added to a base address in order to get to a specific absolute address, Usually the 8-bit byte"
        type            = number
        default         = "4"
}
variable "eks_endpoint_public_access" {
  type = bool
  default = true
}
variable "domain_name" {
  type = string
}

variable "eks_node_groups" {
  type = any
  default = {
    default = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 0

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }  
  }
}

variable "eks_admins_arns" {
  type = list(string)
  default = []
}

variable "internal_domain_name" {
  type = string
  default = "brayest-dev.int"
}

# RDS 
variable "rds_user_name" {
  type = string
  default = "root"
}

variable "rds_engine_version" { 
  type = string
  default = "15.4"
}

variable "create_db_parameter_group" {
  type = bool
  default = false  
}

variable "rds_parameter_group_family" {
  type = string
  default = "aurora-postgresql15"
}

variable "rds_instance_cluster_configuration" {
  type = any
  default = {
    1 = {
      instance_class      = "db.t4g.medium"
    }
  }
}

variable "ingress_replicaCount" {
  type = number
  default = 1
}

variable "rds_deletion_protection" {
  type = bool
  default = false
}
