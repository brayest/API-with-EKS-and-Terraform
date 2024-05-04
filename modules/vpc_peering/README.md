# VPC Peering terraform module

A terraform module to create a VPC peering connection. It supports cross-region and cross-account peering setups.

## Module usage:
```hcl
module "peering" {
  source  = "../modules/vpc_peering"

  # Use different providers for cross-region or cross-account
  providers = {
    aws.requester = aws
    aws.accepter = aws
  }

  requester_vpc_id    = "vpc-09471daea553fe34d"
  accepter_vpc_id     = "vpc-0baa268201f1eae52"
  auto_accept_peering = true
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13.0 |
| aws | ~> 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws.accepter | ~> 3.2.0 |
| aws.requester | ~> 3.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accepter\_allow\_classic\_link\_to\_remote\_vpc | Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC | `bool` | `false` | no |
| accepter\_allow\_remote\_vpc\_dns\_resolution | Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC | `bool` | `true` | no |
| accepter\_allow\_vpc\_to\_remote\_classic\_link | Indicates whether a local VPC can communicate with a ClassicLink connection in the peer VPC over the VPC Peering Connection | `bool` | `false` | no |
| accepter\_route\_table\_ids | List of route tables that will get routes to the requester VPC. If empty and allow\_traffic is enabled, all the route tables of the VPC will get routes (The VPC must be already created before the plan). | `list(string)` | `[]` | no |
| accepter\_vpc\_id | VPC id of the accepter vpc for peering | `string` | `""` | no |
| allow\_traffic\_to\_accepter | If traffic to the accepter VPC (from requester) should be allowed | `bool` | `true` | no |
| allow\_traffic\_to\_requester | If traffic to the requester VPC (from accepter) should be allowed | `bool` | `true` | no |
| auto\_accept\_peering | Auto accept peering connection | `bool` | `false` | no |
| name | Name to be used on all the resources as identifier | `string` | `""` | no |
| requester\_allow\_classic\_link\_to\_remote\_vpc | Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC | `bool` | `false` | no |
| requester\_allow\_remote\_vpc\_dns\_resolution | Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC | `bool` | `true` | no |
| requester\_allow\_vpc\_to\_remote\_classic\_link | Indicates whether a local VPC can communicate with a ClassicLink connection in the requester VPC over the VPC Peering Connection | `bool` | `false` | no |
| requester\_route\_table\_ids | List of route tables that will get routes to the accepter VPC. If empty and allow\_traffic is enabled, all the route tables of the VPC will get routes (The VPC must be already created before the plan). | `list(string)` | `[]` | no |
| requester\_vpc\_id | VPC id of the requester vpc for peering | `string` | `""` | no |
| tags | Tags to be applied to the resource | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| accepter\_options | VPC Peering Connection options set for the accepter VPC |
| accepter\_owner\_id | The AWS account ID of the owner of the accepter VPC |
| accepter\_region | The region of the accepter VPC |
| accepter\_routes | Routes to the accepter VPC |
| accepter\_vpc\_id | The ID of the accepter VPC |
| aws\_vpc\_peering\_connection | n/a |
| aws\_vpc\_peering\_connection\_accepter | n/a |
| requester\_options | VPC Peering Connection options set for the requester VPC |
| requester\_owner\_id | The AWS account ID of the owner of the requester VPC |
| requester\_region | The region of the requester VPC |
| requester\_routes | Routes from the requester VPC |
| requester\_vpc\_id | The ID of the requester VPC |
| vpc\_peering\_accept\_status | Accept status for the connection |
| vpc\_peering\_id | Peering connection ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
