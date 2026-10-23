# 1. Define the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  # 2. Create the core VPC (Virtual Private Cloud) Network


  tags = {
    Name = "Dev-Automation-VPC"
  }
}

# 3. Create a Public Subnet (For web entry points)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Web-Tier"
  }
}


# 4. Create a Security Group (Virtual Firewall)
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  # Inbound Rule: Allow Web Browsers on Port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the public internet
  }

  # Outbound Rule: Allow server to talk to anything (e.g., download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-Web-SG"
  }
}

# 5. Provision an EC2 Virtual Server
resource "aws_instance" "web_server" {
  ami           = "ami-0ddfba243ccee3768" # Amazon Linux 2023 AMI ID for ap-south-1 (Mumbai)
  instance_type = "t2.micro"              # Covered under the AWS Free Tier

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User Data script runs automatically on startup
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from AWS DevOps Automation!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Dev-App-Server"
  }
}
