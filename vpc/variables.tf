variable "name" {
  description = "Name"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDR list"
  type        = list(any)
}

variable "private_subnets" {
  description = "Private subnet CIDR list"
  type        = list(any)
}

variable "azs" {
  description = "Availability zone list"
  type        = list(any)
}

variable "proxy_instance" {
  description = "proxy instnace id list"
  type        = list(any)
}

variable "s3_bucket_arn" {
  description = "s3 bucket arn"
  type        = string
}