variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "vpc_range" {
  type    = string
  default = "10.123.0.0/16"
}

variable "subnets_list" {
  description = "List of AWS subnets"
  type        = list(string)
}

variable "k8s_nodes_list" {
  description = "List of EC2 instances"
  type        = list(string)
}

