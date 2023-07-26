resource "aws_key_pair" "key_pair" {
  key_name   = "connect_key"
  public_key = file("./id_rsa.pub")
}

resource "aws_instance" "k8s_controller" {
  subnet_id                   = aws_subnet.k8s_subnets[0].id
  ami                         = "ami-09420243907777c4a"
  instance_type               = "t2.large"
  key_name                    = aws_key_pair.key_pair.id
  user_data                   = file("./user_data/user_data_controller.sh")
  security_groups             = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "controller"
  }

  provisioner "local-exec" {
    command = "until scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i id_rsa ubuntu@${aws_instance.k8s_controller.public_ip}:/home/ubuntu/join.sh .; do echo \"Waiting for file\"; sleep 10; done"
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
  user_data = file("./user_data/user_data_controller.sh")
  tags = {
    Name = "node-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "while [ ! -f ./join.sh ]; do echo \"Waiting for join script from the controller\"; sleep 10; done && until scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=120 -i id_rsa ./join.sh ubuntu@${self.public_ip}:/home/ubuntu/join.sh; do; echo \"Retrying to connect in 10 seconds...\" sleep 10;"
  }

}

