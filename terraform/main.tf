provider "aws" {
	region = var.region
}

# create vpc
resource "aws_vpc" "eng130-benedek-vpc" {
  	cidr_block = var.vpc_cidr
  	tags = {
    	Name = "eng130-benedek-vpc"
  	}
}

# create internet gateway
resource "aws_internet_gateway" "eng130-benedek-ig" {
  	vpc_id = aws_vpc.eng130-benedek-vpc.id
  	tags = {
    	Name = "eng130-benedek-ig"
  	}
}

# create subnet
resource "aws_subnet" "eng130-benedek-subnet" {
  	vpc_id = aws_vpc.eng130-benedek-vpc.id
	availability_zone = var.az
  	cidr_block = var.subnet_cidr
  	tags = {
    	Name = "eng130-benedek-subnet"
  	}
}

# create route table
resource "aws_route_table" "eng130-benedek-rt" {
  	vpc_id = aws_vpc.eng130-benedek-vpc.id
  	route {
    	cidr_block = var.anyone_cidr
    	gateway_id = aws_internet_gateway.eng130-benedek-ig.id
  	}
  	tags = {
    	Name = "eng130-benedek-rt"
  	}
}

# attach route table to subnet
resource "aws_route_table_association" "eng130-benedek-subnet-rt" {
	subnet_id = aws_subnet.eng130-benedek-subnet.id
  	route_table_id = aws_route_table.eng130-benedek-rt.id
}

# create security group
resource "aws_security_group" "eng130-benedek-terraform-sg" {
  	name = "eng130-benedek-terraform-sg"
  	description = "eng130-benedek-terraform-sg"
  	vpc_id = aws_vpc.eng130-benedek-vpc.id
  	ingress {
    	description = "SSH"
    	from_port = var.ssh_port
    	to_port = var.ssh_port
    	protocol = "tcp"
    	cidr_blocks = [var.anyone_cidr]
  	}
	egress {
    	from_port = 0
    	to_port = 0
    	protocol = "-1"
    	cidr_blocks = [var.anyone_cidr]
  	}
  	tags = {
    	Name = "allow tls"
  	}
}

# create instance
resource "aws_instance" "eng130-benedek-ec2-instance" {
	key_name = var.key_name
	ami = var.ami
	instance_type = var.instance_type
	associate_public_ip_address = true
	subnet_id = aws_subnet.eng130-benedek-subnet.id
	vpc_security_group_ids = [aws_security_group.eng130-benedek-terraform-sg.id]
	tags = {
		Name = "eng130-benedek-terraform-app"		
	}
}