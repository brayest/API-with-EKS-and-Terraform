variable "cluster_name" {
  type = string
}
variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}
variable "private_ingress" {
  type = bool
  default = false
}
variable "private_subnets" {
  type = string
  default = ""
}
variable "vpc_link_enabled" {
  type = bool
  default = false
}
variable "replicaCount" {
  type = number
  default = 1
}