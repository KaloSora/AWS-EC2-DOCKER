module "ec2-docker" {
  source = "./ec2-docker"
  ec2_key_name = var.ec2_key_name
  ec2_ssh_inbound_cidr = var.ec2_ssh_inbound_cidr
  ec2_instance_type = var.ec2_instance_type
  ec2_subnet_id = var.aws_subnet_id
}