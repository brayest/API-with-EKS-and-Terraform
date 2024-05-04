terraform {
  backend "s3" {
    encrypt = true
  }
}

data "terraform_remote_state" "beam3_utility" {
  backend = "s3"
  config = {
    profile = local.utility_aws_profile
    bucket = local.utility_bucket
    key    = "terraform.tfstate"
    region = local.utility_region
  }
}