data "aws_ami" "latest_rhel8" {
  most_recent = true
  owners      = ["309956199498"] # RedHat owner ID

  filter {
    name   = "name"
    values = ["RHEL-8.*_HVM-*-x86_64-*Hourly2-GP3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }
}
