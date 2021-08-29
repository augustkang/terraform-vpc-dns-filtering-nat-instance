variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "keypair" {
  description = "ssh key"
  type        = string
}

variable "public_subnets" {
  description = "proxy instance subnet id"
  type        = list(any)
}

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type        = list(any)
}

variable "private_subnets" {
  description = "private instance subnet id"
  type        = list(any)
}

variable "private_subnet_cidr" {
  description = "private subnet cidr"
  type        = list(any)
}

variable "proxy_instance_type" {
  description = "instance type"
  type        = string
}

variable "private_instance_type" {
  description = "instance type"
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "prefix_list_id" {
  description = "prefix list id for VPC endpoint"
  type        = string
}
