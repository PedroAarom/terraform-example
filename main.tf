provider "aws" {
 region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
 
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidr
 availability_zone = var.availability_zone
 map_public_ip_on_launch = true
 
 tags = {
   Name = "Public Subnet"
 }
}

resource "aws_subnet" "private_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = var.private_subnet_cidr
 availability_zone = var.availability_zone
 map_public_ip_on_launch = false
 tags = {
   Name = "Private Subnet"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "my-igw"
 }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_as" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "example" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = aws_subnet.public_subnet.id
  tags = {
    Name = "example-instance"
  }
  vpc_security_group_ids  = ["${aws_security_group.ec2_sg.id}"]
  user_data = <<-EOF
	      #!/bin/bash
	      sudo yum update -y && sudo yum install httpd -y && sudo systemctl start httpd && sudo systemctl enable httpd
	      EOF
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}