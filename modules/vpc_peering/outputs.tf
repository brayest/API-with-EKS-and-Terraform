output "aws_vpc_peering_connection" {
  value = aws_vpc_peering_connection.this
}

output "aws_vpc_peering_connection_accepter" {
  value = aws_vpc_peering_connection_accepter.this
}

output "vpc_peering_id" {
  description = "Peering connection ID"
  value       = aws_vpc_peering_connection.this.id
}

output "vpc_peering_accept_status" {
  description = "Accept status for the connection"
  value       = aws_vpc_peering_connection_accepter.this.accept_status
}

#  ############### Requester ##############

output "requester_vpc_id" {
  description = "The ID of the requester VPC"
  value       = var.requester_vpc_id
}

output "requester_owner_id" {
  description = "The AWS account ID of the owner of the requester VPC"
  value       = data.aws_caller_identity.requester.account_id
}

output "requester_region" {
  description = "The region of the requester VPC"
  value       = data.aws_region.requester.name
}

output "requester_options" {
  description = "VPC Peering Connection options set for the requester VPC"
  value       = aws_vpc_peering_connection.this.requester
}

output "requester_routes" {
  description = "Routes from the requester VPC"
  value       = tolist(aws_route.requester_routes.*)
}

#  ############### Acccepter ##############

output "accepter_vpc_id" {
  description = "The ID of the accepter VPC"
  value       = var.accepter_vpc_id
}

output "accepter_owner_id" {
  description = "The AWS account ID of the owner of the accepter VPC"
  value       = data.aws_caller_identity.accepter.account_id
}

output "accepter_region" {
  description = "The region of the accepter VPC"
  value       = aws_vpc_peering_connection_accepter.this.peer_region
}

output "accepter_options" {
  description = "VPC Peering Connection options set for the accepter VPC"
  value       = aws_vpc_peering_connection_accepter.this.accepter
}

output "accepter_routes" {
  description = "Routes to the accepter VPC"
  value       = tolist(aws_route.accepter_routes.*)
}
