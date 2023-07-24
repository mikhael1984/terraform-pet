output "controller_ip" {
  value = aws_instance.k8s_controller.public_ip
}

output "node-1_ip" {
  value = aws_instance.k8s_nodes.*.public_ip
}
