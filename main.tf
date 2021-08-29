provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"
}

module "vpc" {
  source          = "./vpc"
  name            = "basic-vpc"
  cidr            = "10.193.0.0/16"
  azs             = ["${local.region}a", "${local.region}c"]
  public_subnets  = ["10.193.0.0/24", "10.193.1.0/24"]
  private_subnets = ["10.193.2.0/24", "10.193.3.0/24"]
  proxy_instance  = module.ec2.proxy_instances
  s3_bucket_arn   = module.s3.s3_bucket_arn
}

module "ec2" {
  source = "./ec2"

  ami                   = "ami-02af1a55fd4da5ab1" # amazon linux 2
  keypair               = "test"                  # PUT KEYPAIR
  proxy_instance_type   = "t3.micro"
  private_instance_type = "t2.micro"
  public_subnets        = module.vpc.public_subnet
  private_subnets       = module.vpc.private_subnet
  vpc_id                = module.vpc.vpc_id
  public_subnet_cidr    = module.vpc.public_subnet_cidr
  private_subnet_cidr   = module.vpc.private_subnet_cidr
  prefix_list_id        = module.vpc.prefix_list_id
}

module "s3" {
  source = "./s3"

  bucket_name     = "example-bucket-for-vpc-terraform"
  vpc_endpoint_id = module.vpc.vpc_endpoint_id
}