resource "aws_security_group" "ssh_sg" {
  name        = "ssh-sg"
  description = "Allow SSH"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "proxy_sg" {
  count       = length(var.public_subnets)
  name        = "proxy-sg-${count.index}"
  description = "Allow private subnet instance"

  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr[count.index]]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr[count.index]]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr[count.index]]
  }

}

resource "aws_security_group" "private_sg" {
  count       = length(var.private_subnets)
  name        = "private-sg-${count.index}"
  description = "Allow private subnet instance"

  vpc_id = var.vpc_id
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = [var.prefix_list_id]
  }
  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = [var.prefix_list_id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy_sg[count.index].id]
  }
}

resource "aws_instance" "proxy_instance" {
  count = length(var.public_subnets)

  ami                         = var.ami
  instance_type               = var.proxy_instance_type
  key_name                    = var.keypair
  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = file("ec2/proxy_userdata.sh")

  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.proxy_sg[count.index].id
  ]
  tags = { Name = "proxy-instance-${count.index}" }
}

resource "aws_instance" "private_instance" {
  count = length(var.public_subnets)

  ami           = var.ami
  instance_type = var.private_instance_type
  key_name      = var.keypair
  subnet_id     = var.private_subnets[count.index]

  vpc_security_group_ids = [aws_security_group.private_sg[count.index].id]
  tags                   = { Name = "private-instance-${count.index}" }
}