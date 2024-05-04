variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "requester_vpc_id" {
  description = "VPC id of the requester vpc for peering"
  default     = ""
  type        = string
}

variable "accepter_vpc_id" {
  description = "VPC id of the accepter vpc for peering"
  default     = ""
  type        = string
}

variable "auto_accept_peering" {
  description = "Auto accept peering connection"
  type        = bool
  default     = false
}

#  ############ Peering Options ###########

variable "requester_allow_remote_vpc_dns_resolution" {
  description = "Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC"
  type        = bool
  default     = true
}


variable "accepter_allow_remote_vpc_dns_resolution" {
  description = "Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC"
  type        = bool
  default     = true
}

#  ############ Routing Options ###########

variable "allow_traffic_to_accepter" {
  description = "If traffic to the accepter VPC (from requester) should be allowed"
  type        = bool
  default     = true
}

variable "allow_traffic_to_requester" {
  description = "If traffic to the requester VPC (from accepter) should be allowed"
  type        = bool
  default     = true
}

variable "requester_route_table_ids" {
  description = "List of route tables that will get routes to the accepter VPC. If empty and allow_traffic is enabled, all the route tables of the VPC will get routes (The VPC must be already created before the plan)."
  type        = list(string)
  default     = []
}

variable "accepter_route_table_ids" {
  description = "List of route tables that will get routes to the requester VPC. If empty and allow_traffic is enabled, all the route tables of the VPC will get routes (The VPC must be already created before the plan)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}

variable "accepter_cidr_block" {
  type = string
  default = null
}

variable "requester_cidr_block" {
  type = string
  default = null
}
