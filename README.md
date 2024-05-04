### Infrastructure Requirements
1. **AWS Account**: An active AWS account is needed to provision resources like EKS (Elastic Kubernetes Service), storage, etc.
2. **Terraform**: Install Terraform to define and deploy the infrastructure as code.
3. **kubectl**: Required for interacting with the Kubernetes cluster once it's deployed.
4. **AWS CLI**: To configure AWS credentials locally and interact with AWS services.

### Software Requirements
1. **Docker**: Necessary for building and running Docker images, including the API's Dockerfile.
2. **Helm**: Install Helm to manage Kubernetes applications and deploy the Helm charts available in the project.

### CI/CD Requirements
1. **GitHub Actions**: For automatic deployment using the predefined workflow.
   - Ensure that you have access to a GitHub repository and can configure the required secrets to interact with AWS and the cluster.

### Project Setup Instructions
1. **Docker Images**:
   - Build the Docker image for the API using the provided Dockerfile:
     ```bash
     cd ./application/api/
     docker build -t <ECR_URL> . 
     ```
   - Push the image to the ECR repository

2. **Terraform Configuration**:
   - Review and adjust the Terraform variables in `terraform.tfvars` to suit your environment in the `dev` folder.
   - Run `terraform init` to initialize the environment, followed by `terraform apply` to create the infrastructure.

4. **Database Creation**:
    - Create an EC2 instance or a Jump host to access the internal DB
    - Create the database called `api`

3. **CI/CD Pipeline**:
   - Ensure that the GitHub Actions pipeline is configured with appropriate AWS credentials and is triggered by a push or pull request.
   - Adjust the `.github/workflows/workflow.yaml` file as necessary to meet your deployment needs.
   - The Pipeline is just an example, is puposly incomplete since for it to be functional the github runners need to be authenticated 


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora"></a> [aurora](#module\_aurora) | ../modules/aurora | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ../modules/cert_manager | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ../modules/cluster_autoscaler | n/a |
| <a name="module_ebs_csi"></a> [ebs\_csi](#module\_ebs\_csi) | ../modules/iam/iam-role-for-service-accounts-eks | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../modules/eks | n/a |
| <a name="module_eks_admin_role"></a> [eks\_admin\_role](#module\_eks\_admin\_role) | ../modules/iam/iam-assumable-role | n/a |
| <a name="module_ingress_controller"></a> [ingress\_controller](#module\_ingress\_controller) | ../modules/ingress_controller | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../modules/vpc | n/a |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | ../modules/iam/iam-role-for-service-accounts-eks | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.eks_admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.rds_record_set_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.rds_record_set_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.internal_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_secretsmanager_secret.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.rds_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_policy.rds_credentials_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy) | resource |
| [aws_secretsmanager_secret_version.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.rds_credentials_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group_rule.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [kubernetes_daemonset.ssm_installer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_storage_class.ebs_storage_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.eks_admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.public_domain_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs_count"></a> [azs\_count](#input\_azs\_count) | n/a | `number` | `3` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | `"1.22"` | no |
| <a name="input_create_db_parameter_group"></a> [create\_db\_parameter\_group](#input\_create\_db\_parameter\_group) | n/a | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `string` | n/a | yes |
| <a name="input_eks_admins_arns"></a> [eks\_admins\_arns](#input\_eks\_admins\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_eks_endpoint_public_access"></a> [eks\_endpoint\_public\_access](#input\_eks\_endpoint\_public\_access) | n/a | `bool` | `true` | no |
| <a name="input_eks_node_groups"></a> [eks\_node\_groups](#input\_eks\_node\_groups) | n/a | `any` | <pre>{<br>  "default": {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_capacity": 1,<br>    "instance_types": [<br>      "t3.medium"<br>    ],<br>    "max_capacity": 2,<br>    "min_capacity": 0<br>  }<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"dev"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| <a name="input_ingress_replicaCount"></a> [ingress\_replicaCount](#input\_ingress\_replicaCount) | n/a | `number` | `1` | no |
| <a name="input_internal_domain_name"></a> [internal\_domain\_name](#input\_internal\_domain\_name) | n/a | `string` | `"beam4-qa.int"` | no |
| <a name="input_number_subnets"></a> [number\_subnets](#input\_number\_subnets) | n/a | `number` | `3` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | n/a | `bool` | `false` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | n/a | `string` | `"beam4_qa"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `"beam4"` | no |
| <a name="input_rds_ca_cert_identifier"></a> [rds\_ca\_cert\_identifier](#input\_rds\_ca\_cert\_identifier) | n/a | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_rds_deletion_protection"></a> [rds\_deletion\_protection](#input\_rds\_deletion\_protection) | n/a | `bool` | `false` | no |
| <a name="input_rds_engine_version"></a> [rds\_engine\_version](#input\_rds\_engine\_version) | n/a | `string` | `"15.4"` | no |
| <a name="input_rds_instance_cluster_configuration"></a> [rds\_instance\_cluster\_configuration](#input\_rds\_instance\_cluster\_configuration) | n/a | `any` | <pre>{<br>  "1": {<br>    "instance_class": "db.t4g.medium"<br>  }<br>}</pre> | no |
| <a name="input_rds_parameter_group_family"></a> [rds\_parameter\_group\_family](#input\_rds\_parameter\_group\_family) | n/a | `string` | `"aurora-postgresql15"` | no |
| <a name="input_rds_user_name"></a> [rds\_user\_name](#input\_rds\_user\_name) | RDS | `string` | `"root"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_set_alarms"></a> [set\_alarms](#input\_set\_alarms) | n/a | `bool` | `false` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_utility_role_arn"></a> [utility\_role\_arn](#input\_utility\_role\_arn) | n/a | `string` | `null` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | `"10.100.0.0/16"` | no |
| <a name="input_vpc_offset"></a> [vpc\_offset](#input\_vpc\_offset) | Denotes the number of address locations added to a base address in order to get to a specific absolute address, Usually the 8-bit byte | `number` | `"4"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_cluster_endpoint"></a> [aurora\_cluster\_endpoint](#output\_aurora\_cluster\_endpoint) | n/a |
| <a name="output_aurora_cluster_master_secret"></a> [aurora\_cluster\_master\_secret](#output\_aurora\_cluster\_master\_secret) | n/a |
| <a name="output_cluster_config"></a> [cluster\_config](#output\_cluster\_config) | n/a |
| <a name="output_eks_admin_role"></a> [eks\_admin\_role](#output\_eks\_admin\_role) | n/a |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | n/a |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | n/a |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | n/a |
| <a name="output_eks_cluster_oidc_issuer_url"></a> [eks\_cluster\_oidc\_issuer\_url](#output\_eks\_cluster\_oidc\_issuer\_url) | n/a |
| <a name="output_environment_tags"></a> [environment\_tags](#output\_environment\_tags) | n/a |
| <a name="output_internal_domain_id"></a> [internal\_domain\_id](#output\_internal\_domain\_id) | n/a |
| <a name="output_internal_domain_name"></a> [internal\_domain\_name](#output\_internal\_domain\_name) | n/a |
| <a name="output_internal_domain_zone_id"></a> [internal\_domain\_zone\_id](#output\_internal\_domain\_zone\_id) | n/a |
| <a name="output_internal_load_balancer_endpoint"></a> [internal\_load\_balancer\_endpoint](#output\_internal\_load\_balancer\_endpoint) | n/a |
| <a name="output_internal_loadbalancer_arn"></a> [internal\_loadbalancer\_arn](#output\_internal\_loadbalancer\_arn) | n/a |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | List of Elastic IPs associated with NAT gateways |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of private Route Table IDs |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of private subnet IDs |
| <a name="output_public_domain"></a> [public\_domain](#output\_public\_domain) | Public domain name |
| <a name="output_public_domain_hosted_zone_id"></a> [public\_domain\_hosted\_zone\_id](#output\_public\_domain\_hosted\_zone\_id) | n/a |
| <a name="output_public_load_balancer_endpoint"></a> [public\_load\_balancer\_endpoint](#output\_public\_load\_balancer\_endpoint) | n/a |
| <a name="output_rds_record_set_reader"></a> [rds\_record\_set\_reader](#output\_rds\_record\_set\_reader) | n/a |
| <a name="output_rds_record_set_writer"></a> [rds\_record\_set\_writer](#output\_rds\_record\_set\_writer) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR |
| <a name="output_vpc_config"></a> [vpc\_config](#output\_vpc\_config) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |


