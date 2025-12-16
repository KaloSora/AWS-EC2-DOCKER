module "k8s-cvm" {
  source = "./ec2-docker"
  ec2_key_name = var.ec2_key_name
}