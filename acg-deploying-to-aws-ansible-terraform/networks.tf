# Create VPC in us-east-1
resource "aws_vpc" "vpc_chief" {
  provider             = aws.region-chief
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "name" = "chief-vpc-jenkins"
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
resource "aws_internet_gateway" "vpc_chief" {
  provider = aws.region-chief
  vpc_id   = aws_vpc.vpc_chief.id
}

# Create IGW in us-west-2
resource "aws_internet_gateway" "vpc_worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
}

# Get all available AZ's in VPC for chief region
data "aws_availability_zones" "vpc_chief" {
  provider = aws.region-chief
  state    = "available"
}

# Get all available AZ's in VPC for worker region
data "aws_availability_zones" "vpc_worker" {
  provider = aws.region-worker
  state    = "available"
}

# Create subnet 1 for chief VPC
resource "aws_subnet" "vpc_chief_1" {
  provider          = aws.region-chief
  availability_zone = element(data.aws_availability_zones.vpc_chief.names, 0)
  vpc_id            = aws_vpc.vpc_chief.id
  cidr_block        = "10.0.1.0/24"
}

# Create subnet 2 for chief VPC
resource "aws_subnet" "vpc_chief_2" {
  provider          = aws.region-chief
  availability_zone = element(data.aws_availability_zones.vpc_chief.names, 1)
  vpc_id            = aws_vpc.vpc_chief.id
  cidr_block        = "10.0.2.0/24"
}

# Create subnet 1 for worker VPC
resource "aws_subnet" "vpc_worker_1" {
  provider          = aws.region-worker
  availability_zone = element(data.aws_availability_zones.vpc_worker.names, 0)
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.1.0/24"
}

# Create subnet 2 for worker VPC
resource "aws_subnet" "vpc_worker_2" {
  provider          = aws.region-worker
  availability_zone = element(data.aws_availability_zones.vpc_worker.names, 1)
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.2.0/24"
}