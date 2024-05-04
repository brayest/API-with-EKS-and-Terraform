variable "cluster_name" {
  type = string
  default = "Cluster"
}
variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}

variable "notifications_email" {
  type = string
}

variable "create_private_issuer" {
  type = bool
  default = false
}

variable "private_domain" {
  type = string 
  default = "beam4-qa.int"
}