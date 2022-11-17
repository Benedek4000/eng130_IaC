variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "subnet_cidr" {
    default = "10.0.7.0/24"
}

variable "anyone_cidr" {
    default = "0.0.0.0/0"
}

variable "ssh_port" {
    default = 22
}

variable "region" {
    default = "eu-west-1"
}

variable "az" {
    default = "eu-west-1a"
}

variable "key_name" {
    default = "eng130"
}

variable "ami" {
    default = "ami-0b47105e3d7fc023e"
}

variable "instance_type" {
    default = "t2.micro"
}