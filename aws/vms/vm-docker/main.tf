provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  vpc_name = format("%s-vpc", var.environment)
  hostname = format("%s-%s", var.environment, var.machine_name)
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  #public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  # One NAT Gateway per subnet
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = local.tags
}


module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.hostname

  instance_type = var.machine_type
  key_name      = "user1"
  monitoring    = true
  #vpc_security_group_ids = ["sg-12345678"]
  subnet_id = "subnet-eddcdzz4"

  tags = local.tags
}
