# Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Network
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = aws_vpc.this.cidr_block
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
}

resource "aws_route" "internet" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# EC2
resource "aws_security_group" "this" {
  name        = "lab-instance-sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "cp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  root_block_device {
    volume_size = 20
  }
  subnet_id = aws_subnet.this.id
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname cp
adduser --quiet --disabled-password --shell /bin/bash --home /home/student --gecos 'Student' student
echo 'student:asdf1234' | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
usermod -aG sudo student
echo 'student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
apt update && apt install -y jq
EOF

  tags = {
    Name = "cp"
  }
  
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "worker1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  root_block_device {
    volume_size = 20
  }
  subnet_id = aws_subnet.this.id
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname worker1
adduser --quiet --disabled-password --shell /bin/bash --home /home/student --gecos 'Student' student
echo 'student:asdf1234' | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
usermod -aG sudo student
echo 'student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
EOF

  tags = {
    Name = "worker1"
  }
  
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "worker2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  root_block_device {
    volume_size = 20
  }
  subnet_id = aws_subnet.this.id
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname worker2
adduser --quiet --disabled-password --shell /bin/bash --home /home/student --gecos 'Student' student
echo 'student:asdf1234' | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
usermod -aG sudo student
echo 'student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
EOF

  tags = {
    Name = "worker2"
  }
  
  lifecycle {
    ignore_changes = [ami]
  }
}

# Output
output "cp_ip_address" {
  value = aws_instance.cp.public_ip
}

output "worker1_ip_address" {
  value = aws_instance.worker1.public_ip
}

output "worker2_ip_address" {
  value = aws_instance.worker2.public_ip
}
