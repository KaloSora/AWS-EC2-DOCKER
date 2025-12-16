
### AWS Provider Configuration
# Matches the [profile default] in ~/.aws/config file
# For secret key, it will read from ~/.aws/credentials file
provider "aws" {
  region  = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket         = "795359014551-terraform-state"
    key            = "tfstate/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }
}
