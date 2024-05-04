# Get account and region info
data "aws_caller_identity" "requester" {
  provider = aws.requester
}
data "aws_region" "requester" {
  provider = aws.requester
}
data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}
data "aws_region" "accepter" {
  provider = aws.accepter
}

# Get vpc info
data "aws_vpc" "requester" {
  provider = aws.requester
  id       = var.requester_vpc_id
}
data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.accepter_vpc_id
}

# Get all route tables from vpcs
data "aws_route_tables" "requester_all" {
  provider = aws.requester
  vpc_id   = var.requester_vpc_id
}
data "aws_route_tables" "accepter_all" {
  provider = aws.accepter
  vpc_id   = var.accepter_vpc_id
}
