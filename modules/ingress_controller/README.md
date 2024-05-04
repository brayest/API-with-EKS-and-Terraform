## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_vpc_link.internal_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [helm_release.ingress_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_lb.internal_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [kubernetes_service.private_ingress_controller_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |
| [kubernetes_service.public_ingress_controller_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_ingress"></a> [private\_ingress](#input\_private\_ingress) | n/a | `bool` | `false` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `string` | `""` | no |
| <a name="input_replicaCount"></a> [replicaCount](#input\_replicaCount) | n/a | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the resource | `map(any)` | `{}` | no |
| <a name="input_vpc_link_enabled"></a> [vpc\_link\_enabled](#input\_vpc\_link\_enabled) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_load_balancer_endpoint"></a> [internal\_load\_balancer\_endpoint](#output\_internal\_load\_balancer\_endpoint) | n/a |
| <a name="output_internal_loadbalancer_arn"></a> [internal\_loadbalancer\_arn](#output\_internal\_loadbalancer\_arn) | n/a |
| <a name="output_public_load_balancer_endpoint"></a> [public\_load\_balancer\_endpoint](#output\_public\_load\_balancer\_endpoint) | n/a |
