resource "aws_key_pair" "key_pair" {
  key_name   = "connect_key"
  public_key = file("./id_rsa.pub")
}

resource "aws_instance" "k8s_controller" {
  subnet_id                   = aws_subnet.k8s_subnets[0].id
  ami                         = "ami-09420243907777c4a"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key_pair.id
  user_data                   = file("./user_data/user_data_controller.sh")
  security_groups             = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "controller"
  }

  provisioner "local-exec" {
    command = "until scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i id_rsa ubuntu@${aws_instance.k8s_controller.public_ip}:/home/ubuntu/join.txt .; do echo \"Waiting for file\"; sleep 10; done"
  }

}

resource "aws_instance" "k8s_nodes" {
  count                       = length(var.k8s_nodes_list)
  subnet_id                   = aws_subnet.k8s_subnets[1].id
  ami                         = "ami-09420243907777c4a"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key_pair.id
  security_groups             = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "node-${count.index + 1}"
  }
}

