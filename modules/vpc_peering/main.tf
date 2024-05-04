locals {

  same_region            = data.aws_region.requester.name == data.aws_region.accepter.name
  same_account           = data.aws_caller_identity.requester.account_id == data.aws_caller_identity.accepter.account_id
  same_acount_and_region = local.same_region && local.same_account

  requester_route_table_ids = length(var.requester_route_table_ids) == 0 ? data.aws_route_tables.requester_all.ids : var.requester_route_table_ids
  accepter_route_table_ids  = length(var.accepter_route_table_ids) == 0 ? data.aws_route_tables.accepter_all.ids : var.accepter_route_table_ids
}

#  ########## Peering Connection ##########

resource "aws_vpc_peering_connection" "this" {
  provider = aws.requester

  vpc_id        = var.requester_vpc_id
  peer_owner_id = data.aws_caller_identity.accepter.account_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_region   = data.aws_region.accepter.name

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    { "Side" = local.same_acount_and_region ? "Both" : "Requester" },
    var.tags
  )
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = var.auto_accept_peering

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    { "Side" = local.same_acount_and_region ? "Both" : "Accepter" },
    var.tags
  )
}

#  ############ Peering Options ###########

resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.requester

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this.id

  requester {
    allow_remote_vpc_dns_resolution  = var.requester_allow_remote_vpc_dns_resolution
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this.id

  accepter {
    allow_remote_vpc_dns_resolution  = var.accepter_allow_remote_vpc_dns_resolution
  }
}

#  ############ Peering Routes ############

resource "aws_route" "requester_routes" {
  provider = aws.requester

  count = var.allow_traffic_to_accepter ? length(local.requester_route_table_ids) : 0

  route_table_id            = element(local.requester_route_table_ids[*], count.index)
  destination_cidr_block    = var.accepter_cidr_block == null ? data.aws_vpc.accepter.cidr_block : var.accepter_cidr_block 
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter_routes" {
  provider = aws.accepter

  count = var.allow_traffic_to_requester ? length(local.accepter_route_table_ids) : 0

  route_table_id            = element(local.accepter_route_table_ids[*], count.index)
  destination_cidr_block    = var.requester_cidr_block == null ? data.aws_vpc.requester.cidr_block : var.requester_cidr_block 
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}