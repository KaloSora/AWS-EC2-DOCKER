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