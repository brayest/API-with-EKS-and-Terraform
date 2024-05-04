
# RDS config
resource "random_password" "master" {
  length = 20
  special  = false
}

resource "aws_secretsmanager_secret" "default" {
  name = "${local.project}-${local.environment}-default-secret-${random_string.this.id}"
  description = "Dummy secret to create default KMS key"
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = "default"
}

data "aws_kms_alias" "secretsmanager" {
  depends_on =[
    aws_secretsmanager_secret_version.default
  ]
  name = "alias/aws/secretsmanager"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${local.project}-${local.environment}-aurora-credentials-${random_string.this.id}"
  description = "Database superuser, root, databse connection values"
  kms_key_id  = data.aws_kms_alias.secretsmanager.id
}

resource "aws_secretsmanager_secret_policy" "rds_credentials_policy" {
  secret_arn = aws_secretsmanager_secret.rds_credentials.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAllPermissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = local.database.master_user_name
    password = random_password.master.result
    engine   = "postgres"
    host     = module.aurora.cluster_endpoint
    port     = "5432"
    dbname   = "${local.environment}_api"    
  })  
}

module "aurora" {
  source  = "../modules/aurora"

  name                  = "${local.project}-${local.environment}"
  engine                = "aurora-postgresql"
  engine_version        = local.database.engine_version
  ca_cert_identifier    = local.database.ca_cert_identifier

  instances = local.database.rds_instance_cluster_configuration

  allow_major_version_upgrade = true

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.custom_subnets.database.subnet_ids
  create_db_subnet_group = true
  publicly_accessible   = false
  create_security_group = true

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = concat(local.vpc_config.vpc_private_subnet_cidr_blocks, local.vpc_config.vpc_public_subnet_cidr_blocks, [data.terraform_remote_state.beam3_utility.outputs.vpc_cidr])
    }
  }

  iam_database_authentication_enabled = false
  manage_master_user_password = false
  master_username = "root"
  master_password = random_password.master.result

  apply_immediately   = true
  skip_final_snapshot = false
  storage_encrypted = true

  create_db_cluster_parameter_group      = local.database.create_db_parameter_group
  db_cluster_parameter_group_name        = local.database.create_db_parameter_group ? "${local.project}-${local.environment}-${local.database.rds_parameter_group_family}" : null
  db_cluster_parameter_group_family      = local.database.rds_parameter_group_family
  db_cluster_parameter_group_description = "${local.project}-${local.environment} ${local.database.rds_parameter_group_family} parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "pg_stat_statements.max"
      value        = "10000"
      apply_method = "pending-reboot"  # Add this line
    },
    {
      name         = "pg_stat_statements.track"
      value        = "all" 
      apply_method = "pending-reboot" # Add this line
    }  
  ]  

  create_db_parameter_group      = local.database.create_db_parameter_group
  db_parameter_group_name        = local.database.create_db_parameter_group ? "${local.project}-${local.environment}-${local.database.rds_parameter_group_family}" : null
  db_parameter_group_family      = local.database.rds_parameter_group_family
  db_parameter_group_description = "${local.project}-${local.environment} ${local.database.rds_parameter_group_family} parameter group"
  db_parameter_group_parameters = [
    {
      name         = "pg_stat_statements.max"
      value        = "10000"
      apply_method = "pending-reboot"  # Add this line
    },
    {
      name         = "pg_stat_statements.track"
      value        = "all" 
      apply_method = "pending-reboot" # Add this line
    }    
  ]

  tags = local.tags
}

resource "aws_route53_record" "rds_record_set_writer" {
  zone_id = aws_route53_zone.internal_domain.zone_id
  name    = "writer-db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.aurora.cluster_endpoint]
}

resource "aws_route53_record" "rds_record_set_reader" {
  zone_id = aws_route53_zone.internal_domain.zone_id
  name    = "reader-db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.aurora.cluster_reader_endpoint]
}
