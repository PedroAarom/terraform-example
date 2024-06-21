provider "aws" {
 region = "us-east-1"
}
terraform {
 backend "s3" {
 bucket = "mybucket2121345"
 key = "path/to/terraform.tfstate"
 region = "us-east-1"
 }
}
# resource "aws_instance" "example" {
#  ami = "ami-08a0d1e16fc3f61ea"
#  instance_type = "t2.micro"
#  tags = {
#  Name = "example-instance"
#  }
# }

resource "aws_instance" "example" {
ami = "ami-08a0d1e16fc3f61ea"
instance_type = "t2.micro"
key_name = "vockey"
tags = {
Name = "example-instance"
}
  vpc_security_group_ids  = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
	      #!/bin/bash
	      sudo yum update -y && sudo yum install httpd -y && sudo systemctl start httpd && sudo systemctl enable httpd
	      EOF
}
 
 
resource "aws_security_group" "instance" {
 
  name = "terraform-example-instance"
 
  ingress {
 
    from_port	  = 80
 
    to_port	    = 80
 
    protocol	  = "tcp"
 
    cidr_blocks	= ["0.0.0.0/0"]
 
  }
    ingress {
 
    from_port	  = 22
 
    to_port	    = 22
 
    protocol	  = "tcp"
 
    cidr_blocks	= ["0.0.0.0/0"]
 
  }
  
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
 
}

 
 
 
output "public_ip" {
 
  value = "${aws_instance.example.public_ip}"
 
}