
# VPC
module "vpc" {
  source  = "../modules/vpc"

  aws_region = local.region

  name = "${local.project}-vpc-${local.environment}"
  cidr = local.vpc_config.vpc_cidr_block
  azs  = slice(data.aws_availability_zones.available.names, 0, local.vpc_config.vpc_availability_zones)

  enable_nat_gateway     = true
  single_nat_gateway     = local.vpc_config.single_nat_gateway
  one_nat_gateway_per_az = local.vpc_config.one_nat_gateway_per_az
  enable_dns_hostnames   = true
  enable_dhcp_options    = true

  # Public subnets
  public_subnets               = local.vpc_config.vpc_public_subnet_cidr_blocks
  public_dedicated_network_acl = true

  # Application subnets
  private_subnets               = local.vpc_config.vpc_private_subnet_cidr_blocks
  private_subnet_suffix         = "private"
  private_dedicated_network_acl = true

  # Database subnets
  custom_subnets = {
    database = {
      subnets                   = local.vpc_config.vpc_data_subnet_cidr_blocks
      subnet_suffix             = "data-intra"
      dedicated_network_acl     = true
      create_subnet_route_table = true
    }
  }  

  tags = local.tags 
}

# Internal Domain
resource "aws_route53_zone" "internal_domain" {
  name = local.internal_domain_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }   
}
