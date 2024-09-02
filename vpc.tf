data "aws_availability_zones" "available_output" {}
    
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "prod_VPC" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

#create IGW
resource "aws_internet_gateway" "gw" {
  tags = {
    Name = "Main IGW"
  }
}

# Create IGW attachment
resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.prod_VPC.id
}

#Create public subnet
resource "aws_subnet" "pub_Sub" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.prod_VPC.id
  cidr_block = var.pub_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.pub-subnet_name[count.index]
  }
}

#Creat route table for public subnet
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.prod_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public route table"
  }
}

# Create association public subnet
resource "aws_route_table_association" "asso_pub_sub" {
    count = length(aws_subnet.pub_Sub)
  subnet_id      = aws_subnet.pub_Sub[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}

#Create private subnet
resource "aws_subnet" "private_Sub" {
    count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.prod_VPC.id
  cidr_block = var.private_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = var.private_subnet_name[count.index]
  }
}

# Crate Elastic IP
resource "aws_eip" "EIP" {
  tags = {
    Name = "Elasic IP"
  }
}

#Create NAT Gateway for private subnet
resource "aws_nat_gateway" "NAT_Gateway" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.pub_Sub[0].id

  tags = {
    Name = "gw NAT"
  }
}

#Creat route table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.prod_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_Gateway.id
  }
  tags = {
    Name = "private route table"
  }
}

# Create association private subnet
resource "aws_route_table_association" "asso_private_sub" {
    count = length(aws_subnet.private_Sub)
  subnet_id      = aws_subnet.private_Sub[count.index].id
  route_table_id = aws_route_table.private_rt.id
}