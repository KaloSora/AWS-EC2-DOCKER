# Purpose: To create EC2 instance with Docker installed
# Author: Yihui Li
# Date: 16 DEC 2025

locals {
  ec2_key_filename = "${path.module}/ssh_key/ec2-key.pem"
}

# Create EC2 key pair
# Important: Do not commit the private key to Github
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2_private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = local.ec2_key_filename
  
  provisioner "local-exec" {
    command = "chmod 600 ${local.ec2_key_filename}"
  }
}

# Upload public key to AWS
# resource "aws_key_pair" "generated_key" {
#   key_name   = "my-ec2-key"
#   public_key = tls_private_key.ec2_key.public_key_openssh
  
#   tags = {
#     Environment = "test"
#     Terraform   = "true"
#   }
# }