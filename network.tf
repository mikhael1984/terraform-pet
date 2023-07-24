resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s_VPC"
  }
}

resource "aws_subnet" "k8s_subnets" {
  vpc_id     = aws_vpc.k8s_vpc.id
  count      = length(var.subnets_list)
  cidr_block = cidrsubnet(aws_vpc.k8s_vpc.cidr_block, 8, count.index + 1)

  tags = {
    Name = (count.index == 0 ? "ctrl-subnet" : "exec-subnet-${count.index}")
  }

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

