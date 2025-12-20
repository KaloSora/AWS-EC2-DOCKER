output "ec2_instance_ip" {
  value = aws_instance.ec2_docker_instance.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.ec2_docker_instance.id
}