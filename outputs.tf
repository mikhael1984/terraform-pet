output "controller_ip" {
  value = aws_instance.k8s_controller.public_ip
}

output "node-1_ip" {
  value = aws_instance.k8s_node_1.public_ip
}

output "node-2_ip" {
  value = aws_instance.k8s_node_2.public_ip
}