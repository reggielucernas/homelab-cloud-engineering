# Create SG for LB, only for TCP/80, TCP/443 and outbound access
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-chief
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_chief.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.default_cidr]
  }
}

# Create SG for allowing TCP/8080 from * and TCP/22 from your IP in us-east-1
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-chief
  name        = "jenkins-sg"
  description = "Allow TCP/8080 and TCP/22"
  vpc_id      = aws_vpc.vpc_chief.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr]
  }
}