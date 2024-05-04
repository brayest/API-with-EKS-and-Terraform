terraform {
  source = "${get_parent_terragrunt_dir()}/..//environment///"
}

generate "nginx_helmignore" {
  path      = "../modules/ingress_controller/nginx-ingress/.helmignore"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
.terragrunt-source-manifest*
  EOF
}

locals {
  indentifier   = "brayest-dev" 
  aws_region    = "us-east-1"  

  backend_bucket = "${local.indentifier}-terraform-state-${local.aws_region}-${get_aws_account_id()}"
  dynamodb_table = "${local.indentifier}-lock-table-${local.aws_region}-${get_aws_account_id()}"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.backend_bucket
    dynamodb_table = local.dynamodb_table
    key            = "terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
  }
}

