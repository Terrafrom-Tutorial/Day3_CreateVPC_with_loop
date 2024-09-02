variable "cidr_block" {
    type = string
  default = "10.10.0.0/16"
}

variable "vpc_name" {
    type = string
  default = "Production VPC"
}

variable "availability_zone" {
  type = list(string)
  default = [ "ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c" ]
}

variable "pub_cidr_block" {
  type = list(string)
  default = [ "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"   ]
}

variable "pub-subnet_name" {
  type = list(string)
  default = [ "public subnet 1", "public subnet 2", "public subnet 3" ]
}

variable "private_cidr_block" {
  type = list(string)
  default = [ "10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"   ]
}

variable "private_subnet_name" {
  type = list(string)
  default = [ "private subnet 1", "private subnet 2", "private subnet 3" ]
}