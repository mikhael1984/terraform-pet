variable "vpc_range" {
  type = string
  default = "10.123.0.0/16"
}

variable "subnet_A_range" {
  type = string
  default = "10.123.1.0/24"
}

variable "subnet_B_range" {
  type = string
  default = "10.123.2.0/24"
}