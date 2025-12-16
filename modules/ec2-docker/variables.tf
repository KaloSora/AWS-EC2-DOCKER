variable "ec2_key_name" {
  type = string
  description = "AWS EC2 key name"
}

variable "ec2_ssh_inbound_cidr" {
  type = list(string)
  description = "AWS EC2 SSH inbound CIDR"
}

variable "ec2_instance_type" {
  type = string
  description = "AWS EC2 instance type"
}

variable "ec2_subnet_id" {
  type = list(string)
  description = "AWS EC2 subnet IDs"
}