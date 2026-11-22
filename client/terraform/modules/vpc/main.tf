
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )
}

# Here we are creating our VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # Turns domain names into IP Addresses
  enable_dns_hostnames = true # Instead of refering to our AWS Resources's IP Address [e.g EC2 instance Private IP Addresses], we can use their DNS Hostnames to identify them

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Here we are creating our Public Subnet 
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.this.id # Here we need to know which vpc our public subnet belongs to
  cidr_block              = var.public_subnet_cidrs[count.index] # Our subnet will have a Private IP Address that is within our VPC's Private Address Range
  availability_zone       = local.availability_zones[count.index] # Our public subnet will be under an availability zone e.g us-east-1a
  map_public_ip_on_launch = true # This tells AWS to automatically assign an IPV4 Address to any resource we launch in our Public Subnet

  tags = {
    Name = "${var.project}-public-subnet-${count.index == 0 ? "a" : "b"}" # Here we are giving our Public Subnet a tag
    Tier = "public" # Here we are labelling our Subnet as public
  }
}


# Here we are creating our Private SUbnet
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.this.id # Here we need to know which vpc our private subnet belongs to
  cidr_block        = var.private_subnet_cidrs[count.index] # Whatever AWS Resource we launch in our Private Subnet [e.g EC2 instance], it will have a Private IP Address that is within our Private Subnet's IP Address Range
  availability_zone = local.availability_zones[count.index] # Our private subnet will be under an availability zone e.g us-east-1a

  tags = {
    Name = "${var.project}-private-subnet-${count.index == 0 ? "a" : "b"}" # Here we are giving our Private Subnet a tag
    Tier = "private" # Here we are labelling our Subnet as private
  }
}


# Here we are creating our Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id # We need to know which VPC our internet gateway belongs to

  tags = {
    Name = "${var.project}-igw" # Here we are giving our internet gateway a tag
  }
}


# Here we are creating our Nat Gateway Elastic IP Address
resource "aws_eip" "nat" {
  domain = "vpc" # This tells AWS the Elastic IP is intended for use with resources in VPC

  depends_on = [aws_internet_gateway.this] # Create an internet gateway first before creating our Nat Gateway Elastic IP 

  tags = {
    Name = "${var.project}-nat-eip" # Here we are giving our EIP a tag
  }
}

# Here we are creating our Nat Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id # Our Nat Gateway will have an Elastic IP Address
  subnet_id     = aws_subnet.public[0].id # We are placing our Nat Gateway inside a Public Subnet [e.g Public Subnet A]

  depends_on = [aws_internet_gateway.this] # Create the internet gateway before creating our Nat Gateway

  tags = {
    Name = "${var.project}-nat-gateway" # Give our Nat Gateway a tag
  }
}

# Here we are creating our route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id # We need to know which VPC our public route belongs to

  route {
    cidr_block = "0.0.0.0/0" # This allows traffic that wants to reach any IPV4 destination
    gateway_id = aws_internet_gateway.this.id # If you want to reach any IPV4 destination, go through the internet gateway
  }

  tags = {
    Name = "${var.project}-public-route-table"  # This is our Tag
    Tier = "public" # labels our route table as public
  }
}


# Here we are creating our private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id # Which VPC our private route table belongs to

  route {
    cidr_block     = "0.0.0.0/0" # Allows traffic that wants to reach any IPV4 Destination
    nat_gateway_id = aws_nat_gateway.this.id # If you want to reach any IPV4 Destination, send traffic through the nat gateway
  }

  tags = {
    Name = "${var.project}-private-route-table" # This is our Tag
    Tier = "private" # labels our route table as private
  }
}


# Here we are associating our public subnet with the public route table
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Here we are associating our Private Subnet with our Private Route table
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}