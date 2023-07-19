resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s_VPC"
  }
}

resource "aws_subnet" "k8s_subnet_A" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnet_A_range
  map_public_ip_on_launch = true
}

resource "aws_subnet" "k8s_subnet_B" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnet_B_range
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_vpc.k8s_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s_igw.id
}

resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  security_group_id = aws_security_group.k8s_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_me" {
  security_group_id = aws_security_group.k8s_sg.id
  cidr_ipv4         = "91.185.25.194/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "TCP"
}

