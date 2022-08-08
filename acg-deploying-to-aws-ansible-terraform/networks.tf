# Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "master-vpc-jenkins"
  }
}

# Create VPC in us-west-2
resource "aws_vpc" "vpc_worker" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "worker-vpc-jenkins"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "vpc_master" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

# Create IGW in us-west-2
resource "aws_internet_gateway" "vpc_worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "vpc_master" {
  provider = aws.region-master
  state    = "available"
}

# Get all available AZ's in VPC for worker region
data "aws_availability_zones" "vpc_worker" {
  provider = aws.region-worker
  state    = "available"
}

# Create subnet 1 for master VPC
resource "aws_subnet" "vpc_master_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.vpc_master.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

# Create subnet 2 for master VPC
resource "aws_subnet" "vpc_master_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.vpc_master.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

# Create subnet for worker VPC
resource "aws_subnet" "vpc_worker_1" {
  provider          = aws.region-worker
  availability_zone = element(data.aws_availability_zones.vpc_worker.names, 0)
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.1.0/24"
}

# Initiate VPC peering connection request from us-east-1
resource "aws_vpc_peering_connection" "uswest1-useast1" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_worker.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker
}

# Accept VPC peering connection request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.uswest1-useast1.id
  auto_accept               = true
}

# Create route table in us-east-1
resource "aws_route_table" "master_vpc_default_rt" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = var.default_cidr
    gateway_id = aws_internet_gateway.vpc_master.id
  }
  route {
    cidr_block                = aws_subnet.vpc_worker_1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.uswest1-useast1.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "master-region-rt"
  }
}

# Overwrite default route table of master VPC with our route table entries
resource "aws_main_route_table_association" "master_vpc_default_rt" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.master_vpc_default_rt.id
}

# Create route table in us-west-2
resource "aws_route_table" "worker_vpc_default_rt" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = var.default_cidr
    gateway_id = aws_internet_gateway.vpc_worker.id
  }
  route {
    cidr_block                = aws_subnet.vpc_master_1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.uswest1-useast1.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "worker-region-rt"
  }
}

# Overwrite default route table of worker VPC with our route table entries
resource "aws_main_route_table_association" "worker_vpc_default_rt" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.worker_vpc_default_rt.id
}