# Use this data source to get the ID of a registered AMI for use in other resources
data "aws_ami" "debian" {
  most_recent      = true
  owners           = ["136693071363"] #owner number for amazon

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"] #amazon machine images (AMIs)
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Provides a VPC resource
resource "aws_vpc" "open_web_ui" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Provides an VPC subnet resource
resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.open_web_ui.cidr_block, 4, 1)
  vpc_id            = aws_vpc.open_web_ui.id
  availability_zone = "us-east-1a"
}

# Provides a resource to create a VPC Internet Gateway
resource "aws_internet_gateway" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
}

# Provides a resource to create a VPC routing table
resource "aws_route_table" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.open_web_ui.id
  }
}

# Provides a resource to create an association between a route table and a 
# subnet or a route table and an internet gateway or virtual private gateway
resource "aws_route_table_association" "open_web_ui" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.open_web_ui.id
}

# Provides a security group resource
resource "aws_security_group" "ssh" {
  name = "allow-all"

  vpc_id = aws_vpc.open_web_ui.id

    # Allow SSH access from anywhere
    # Note: This is not recommended for production environments
    # as it exposes the instance to potential attacks.
    # It is better to restrict access to specific IP addresses.

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provides a security group resource
resource "aws_security_group" "http" {
  name = "allow-all-http"

  vpc_id = aws_vpc.open_web_ui.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Variable to specify the path to the SSH public key
# This key will be used to create an AWS key pair for SSH access
# to the EC2 instances created by this Terraform configuration.
variable "ssh_pub_key" {
  description = "Path to the SSH public key"
  type        = string
}

# A key pair is used to control login access to EC2 instances
resource "aws_key_pair" "open_web_ui" {
  key_name   = "open_web_ui"
  public_key = file(var.ssh_pub_key)
}

# Request a spot instance
resource "aws_spot_instance_request" "cheap_worker" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro" #free instance
  
  tags = {
    Name = "CheapWorker"
  }
}