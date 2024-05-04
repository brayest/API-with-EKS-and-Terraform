output "public_load_balancer_endpoint" {
  value = data.kubernetes_service.public_ingress_controller_service.status.0.load_balancer.0.ingress.0.hostname  
}

output "internal_load_balancer_endpoint" {
  value = var.private_ingress ? data.kubernetes_service.private_ingress_controller_service[0].status.0.load_balancer.0.ingress.0.hostname : null
}

output "internal_loadbalancer_arn" {
  value = var.private_ingress ? data.aws_lb.internal_load_balancer[0].arn : null
}