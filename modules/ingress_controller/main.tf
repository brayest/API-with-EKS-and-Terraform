resource "helm_release" "ingress_controller" {

  name  = "${var.cluster_name}-ic"
  chart = "${path.module}/nginx-ingress"

  values = [
      "${file("${path.module}/nginx-ingress/values.yaml")}"
  ]   

  namespace = "nginx-ingress"
  create_namespace = true

  set {
    name = "controller.allowSnippetAnnotations"
    value = true
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name = "controller.service.internal.enabled"
    value = var.private_ingress
  }

  set {
    name = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = var.private_subnets
  }

  set {
    name = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  
  set {
    name = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internal"
  }    

  set {
    name = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = true
  }

  set {
    name = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = true
  }  

  set {
    name = "controller.replicaCount"
    value = var.replicaCount
  }
}

data "kubernetes_service" "public_ingress_controller_service" { 
  depends_on = [
    helm_release.ingress_controller
  ]
  metadata {
    name = "${var.cluster_name}-ic-ingress-nginx-controller"
    namespace = "nginx-ingress"
  }
}

data "kubernetes_service" "private_ingress_controller_service" {
  count = var.private_ingress ? 1 : 0

  depends_on = [
    helm_release.ingress_controller
  ]
    
  metadata {
    name = "${var.cluster_name}-ic-ingress-nginx-controller-internal"
    namespace = "nginx-ingress"
  }
}

data "aws_lb" "internal_load_balancer" {
  count = var.private_ingress ? 1 : 0

  name = split("-", data.kubernetes_service.private_ingress_controller_service[0].status.0.load_balancer.0.ingress.0.hostname)[0]
}

data "aws_lb" "public_load_balancer" {

  name = split("-", data.kubernetes_service.public_ingress_controller_service.status.0.load_balancer.0.ingress.0.hostname)[0]
}

resource "null_resource" "delay_before_vpc_link" {
  depends_on = [helm_release.ingress_controller]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}


resource "aws_api_gateway_vpc_link" "internal_load_balancer" {
  count = var.vpc_link_enabled ? 1 : 0

  name        = "${var.cluster_name}-ic-ingress-nginx-controller-internal"
  description = "Internal Load Balancer"
  target_arns = [data.aws_lb.internal_load_balancer[0].arn]

  lifecycle {
    ignore_changes = [
      target_arns
    ]
  }  

  tags = var.tags

  depends_on = [
    null_resource.delay_before_vpc_link
  ]  
}
