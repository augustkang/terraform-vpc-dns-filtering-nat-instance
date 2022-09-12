resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = false
  enable_dns_support   = true

  tags = { Name = "vpc" }
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "vpc-dhcp-options-set"
  }
}

resource "aws_vpc_dhcp_options_association" "this" {

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "default-rtb"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index}" }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "private-subnet-${count.index}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = var.proxy_instance[count.index]
  }
  tags = { Name = "private-rt-${count.index}" }
}

resource "aws_route_table_association" "public_route_association" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_route_association" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_route_association" {
  count = length(var.private_subnets)

  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_default_network_acl" "nacl" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
  policy       = <<POLICY
  {
     "Statement":[
        {
           "Action":"*",
           "Effect":"Allow",
           "Resource":"*",
           "Principal":"*"
        }
     ]
  }
  POLICY
}
