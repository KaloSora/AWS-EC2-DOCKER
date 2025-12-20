# Purpose: To create EC2 instance with Docker installed
# Author: Yihui Li
# Date: 16 DEC 2025

locals {
  ec2_key_filename = "${path.module}/ssh_key/ec2-key.pem"
  ec2_key_filename_pub = "${path.module}/ssh_key/ec2-key.pub"
  ec2_timestamp = formatdate("YYYYMMDDHHmmss", timestamp())

  ec2_docker_script = "docker-setup.sh"
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
resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-docker-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
  
  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}

# Create security group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "terraform-ssh-enabled-sg-${local.ec2_timestamp}"
  description = "Allow SSH inbound traffic"
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_ssh_inbound_cidr
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Terraform = "true"
  }
}

# Add System Manager to manager EC2
resource "aws_iam_role" "ssm_role" {
  name = "terraform-ec2-ssm-role-${local.ec2_timestamp}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# Create EC2 instance
resource "aws_instance" "ec2_docker_instance" {
  ami                    = data.aws_ami.latest_rhel8.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = var.ec2_subnet_id[0]
  
  # Attach IAM role for SSM
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "ec2_docker_instance"
    Terraform = "true"
  }
  
  user_data = <<-EOF
            #!/bin/bash
            yum install -y git htop
            timedatectl set-timezone Asia/Shanghai

            # SSM Agent install
            sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
            sudo systemctl start amazon-ssm-agent
            sudo systemctl enable amazon-ssm-agent
            sudo systemctl status amazon-ssm-agent

            # CloudWatch Agent install
            sudo yum install -y amazon-cloudwatch-agent
            sudo systemctl start amazon-cloudwatch-agent
            sudo systemctl enable amazon-cloudwatch-agent
            sudo systemctl status amazon-cloudwatch-agent
        EOF
}

# Setup the EC2
resource "null_resource" "ssh_connection" {

  # No need to set depends_on actually because the resource refer to the public ip already
  # Just a safety measure
  depends_on = [ aws_instance.ec2_docker_instance ]
  
  # Condition: once instance id changes, this module will re-run
  triggers = {
    instance_id = aws_instance.ec2_docker_instance.id
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_docker_instance.public_ip
    user        = "ec2-user" # For AWS RHEL AMI
    private_key = tls_private_key.ec2_key.private_key_pem
    timeout     = "2m"
  }

  # Local-exec provisioner to run commands on your local machine
  provisioner "local-exec" {
    command = <<-EOT
        echo "EC2 Instance IP: ${aws_instance.ec2_docker_instance.public_ip}"
        echo "EC2 ID: ${aws_instance.ec2_docker_instance.id}"
        echo "Use the command to connect: ssh -i ec2-docker/ssh_key/ec2-key.pem ec2-user@${aws_instance.ec2_docker_instance.public_ip}"
    EOT
  }

  # Local script upload with terraform template file
  provisioner "file" {
    source      = "${path.module}/script/${local.ec2_docker_script}"
    destination = "/tmp/${local.ec2_docker_script}"
  }

  # Remote-exec provisioner to run commands on the EC2 instance via SSH
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${local.ec2_docker_script}",

      # FIXME: For Debug
      "echo 'Start docker deployment at $(date)' > /tmp/docker-deployment.log",
      "ls -la /tmp/${local.ec2_docker_script} >> /tmp/docker-deployment.log",

      # Run the setup script
      "sh /tmp/${local.ec2_docker_script} >> /tmp/docker-deployment.log"
    ]
  }
}