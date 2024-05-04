output "cluster_config" {
  value = local.cluster_config
}

output "vpc_config" {
  value = local.vpc_config
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC CIDR"
}

output "public_domain" {
  value       = local.domain_name
  description = "Public domain name"
}

output "internal_domain_id" {
  value = aws_route53_zone.internal_domain.zone_id
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "List of private subnet IDs"
}

output "private_route_table_ids" {
  value       = module.vpc.private_route_table_ids
  description = "List of private Route Table IDs"
}

output "natgw_ids" {
  value       = module.vpc.natgw_ids
  description = "List of Elastic IPs associated with NAT gateways"
}

output "eks_admin_role" {
  value = module.eks_admin_role.iam_role_arn
}


output "internal_loadbalancer_arn" {
  value = module.ingress_controller.internal_loadbalancer_arn
}

output "environment_tags" {
  value = local.tags
}

output "rds_record_set_writer" {
  value = aws_route53_record.rds_record_set_writer.fqdn
}

output "rds_record_set_reader" {
  value = aws_route53_record.rds_record_set_reader.fqdn
}

output "internal_load_balancer_endpoint" {
  value = module.ingress_controller.internal_load_balancer_endpoint
}

output "internal_domain_zone_id" {
  value = aws_route53_zone.internal_domain.id
}

output "public_domain_hosted_zone_id" {
  value = data.aws_route53_zone.public_domain_hosted_zone.id
}
  
output "public_load_balancer_endpoint" {
  value = module.ingress_controller.public_load_balancer_endpoint
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = local.cluster_config.cluster_name
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "internal_domain_name" {
  value = local.internal_domain_name
}
output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "aurora_cluster_endpoint" {
  value = module.aurora.cluster_endpoint
}

output "aurora_cluster_master_secret" {
  value = aws_secretsmanager_secret.rds_credentials.id
}
