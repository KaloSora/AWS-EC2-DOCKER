variable "aws_account_id" {
  type = string
  description = "AWS account ID"
}


variable "aws_region" {
  type = string
  description = "AWS region"
}

variable "aws_vpc_id" {
  type = string
  description = "AWS VPC ID"
}

variable "aws_subnet_id" {
  type = list(string)
  description = "AWS subnet IDs"
}

variable "ec2_instance_type" {
  type = string
  description = "AWS EC2 instance type"
}

variable "ec2_key_name" {
  type = string
  description = "AWS EC2 key name"
}

variable "ec2_ssh_inbound_cidr" {
  type = list(string)
  description = "AWS EC2 SSH inbound CIDR"
}