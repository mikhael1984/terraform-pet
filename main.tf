resource "aws_key_pair" "key_pair" {
  key_name   = "connect_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8FLzPaF3cksRjlGjjyBIdVzbLj6WE0v7avq//5fdWVksgngC44quuLsBh5tRnsX/5WMvaycKRZekTgfi6cYBctc26omsnPJpJAA5SsQlEEV4xQ9mVzO+sR8VWRxFbHZJix7UuCF8mtgo574TL8JzN8oKgz8+PCLAFORxFP3C682TRu1VgDyppkhKgbxKsDsArOlLaH85nTk5xDCH4xHJlBXVXqSWgbIg8CqcmYsDaUcs4p1zXuEMKSclks6zWE+BZLKQVsvvlS86gfwhlmhnRiwsxI23T1O5qiBGudkolqOip2LwHMNfYkkBGthWv7oZ90ip773gwmBk30mVCVxdP"
}

resource "aws_instance" "k8s_controller" {
  subnet_id       = aws_subnet.k8s_subnets[0].id
  ami             = "ami-09420243907777c4a"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.key_pair.id
  user_data       = file("./user_data/user_data_controller.sh")
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "controller"
  }

  provisioner "local-exec" {
    command = "while [ -n ${aws_instance.k8s_controller.public_ip} ]; do echo \"Waiting for controller node setup, sleep for 10 seconds\"; sleep 10; done; scp -i file ubuntu@${aws_instance.k8s_controller.public_ip}/home/ubuntu/join.txt ."
  }

}

resource "aws_instance" "k8s_nodes" {
  count           = length(var.k8s_nodes_list)
  subnet_id       = aws_subnet.k8s_subnets[1].id
  ami             = "ami-09420243907777c4a"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.key_pair.id
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "node-${count.index + 1}"
  }
}

