resource "aws_ecr_repository" "application" {

  name                 = "${local.project}-api"
  image_tag_mutability = "MUTABLE"
  
  encryption_configuration {
      encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_route53_record" "application" {
  zone_id = data.aws_route53_zone.public_domain_hosted_zone.zone_id
  name    = "api.${local.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [module.ingress_controller.public_load_balancer_endpoint]
}

resource "helm_release" "api" {
    depends_on = [
        module.eks,
        aws_route53_record.application
    ]

    name             = "api"
    chart            = "../application/deploy/api"
    namespace        = "default"

    values = [
        "${file("../application/deploy/api/values.yaml")}"
    ]     

    set {
        name  = "replicaCount"
        value = 3
    }

    set {
        name  = "image.repository"
        value = aws_ecr_repository.application.repository_url
    }  

    set {
        name  = "image.tag"
        value = "v2"
    }

    set {
        name = "settings.domain"
        value = local.domain_name
    }

    set {
        name = "database.host"
        value = "writer-db.beam4-qa.int"
    }

    set {
        name = "database.port"
        value = "5432"
    }

    set {
        name = "database.database"
        value = "api"
    }

    set {
        name = "database.user"
        value = local.database.master_user_name
    }

    set {
        name = "database.password"
        value = random_password.master.result
    }
}
