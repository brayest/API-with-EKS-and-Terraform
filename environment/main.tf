
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

  vpc {
    vpc_id = data.terraform_remote_state.beam3_utility.outputs.vpc_id
  }  
}

# Utility access to Dev internal hosted zone
resource "aws_route53_vpc_association_authorization" "utility" {
  vpc_id  = data.terraform_remote_state.beam3_utility.outputs.vpc_id
  vpc_region = local.utility_region
  zone_id = aws_route53_zone.internal_domain.id
}

resource "aws_route53_zone_association" "utility" {
  provider = aws.utility

  vpc_region = local.utility_region
  vpc_id  = data.terraform_remote_state.beam3_utility.outputs.vpc_id
  zone_id = aws_route53_zone.internal_domain.id
}

# Dev access to Utility internal hosted zone
resource "aws_route53_vpc_association_authorization" "dev" {
  provider = aws.utility

  vpc_id  = module.vpc.vpc_id
  vpc_region = local.region
  zone_id = data.terraform_remote_state.beam3_utility.outputs.utility_internal_hosted_zone
}

resource "aws_route53_zone_association" "dev" {

  vpc_id  = module.vpc.vpc_id
  vpc_region = local.region
  zone_id = data.terraform_remote_state.beam3_utility.outputs.utility_internal_hosted_zone
}

# VPC peering
module "utility_peering" {
  source = "../modules/vpc_peering"

  providers = {
    aws.requester = aws
    aws.accepter  = aws.utility
  }

  name = "${local.environment}-utility"

  requester_vpc_id = module.vpc.vpc_id
  accepter_vpc_id  = data.terraform_remote_state.beam3_utility.outputs.vpc_id

  requester_route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids, module.vpc.custom_subnets.database.route_table_ids)
  accepter_route_table_ids  = concat(data.terraform_remote_state.beam3_utility.outputs.private_route_table_ids, data.terraform_remote_state.beam3_utility.outputs.database_route_table_ids)

  auto_accept_peering = true

  tags = local.tags
}

# VPN access
resource "aws_ec2_client_vpn_authorization_rule" "utility_vpn_ingress_rule" {
  provider = aws.utility

  client_vpn_endpoint_id = data.terraform_remote_state.beam3_utility.outputs.utility_vpn_endpoint_id
  target_network_cidr    = local.vpc_config.vpc_cidr_block
  authorize_all_groups   = true
}
resource "aws_ec2_client_vpn_route" "utility_vpn_route" {
  provider = aws.utility

  client_vpn_endpoint_id = data.terraform_remote_state.beam3_utility.outputs.utility_vpn_endpoint_id
  destination_cidr_block = local.vpc_config.vpc_cidr_block
  target_vpc_subnet_id   = data.terraform_remote_state.beam3_utility.outputs.private_subnet_ids[0]
}