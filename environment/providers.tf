terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }

    random = {
      source  = "hashicorp/random"
    }

    local = {
      source  = "hashicorp/local"
    }

    null = {
      source  = "hashicorp/null"
    }

    cloudinit = {
      source = "hashicorp/cloudinit"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
    }

    helm = {
      source  = "hashicorp/helm"
    }    

    http = {
      source = "terraform-aws-modules/http"
    }    
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token    
  }
}