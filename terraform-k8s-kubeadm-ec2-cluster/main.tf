# Terraform AWS Provider - https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure options
provider "aws" {
  region = "us-west-2"
}


resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "kubernetes-cluster-2"
  }
}

# Defile any local vars
locals {
  pem_file     = "./k8s-kp-2.pem"
  key_name     = "k8s-kp-2"
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




# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ${local.pem_file}
      echo '${tls_private_key.rsa_key.private_key_pem}' > ${local.pem_file}
      chmod 400 ${local.pem_file}
      ls -l ${local.pem_file} > /tmp/out
    EOT
  }
}

resource "aws_security_group" "ec2_sg_control_plane" {
  name        = "lab-sg-kube-control"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.sg_control_plane_tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ec2_sg_worker" {
  name        = "lab-sg-kube-worker"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.sg_worker_node_tags
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2_instance_control_plane_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.cp_instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg_control_plane.id]
  subnet_id = aws_subnet.this.id
  tags = {
    Name = "cp"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa_key.private_key_openssh
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    scripts = [
      "./kubeadm-scripts/step-01-k8s-packages-ubuntu.sh",
      "./kubeadm-scripts/step-02-k8s-cp-init.sh",
    ]
  }
  provisioner "local-exec" {
    command = <<-EOT
      join_cmd=$(ssh ubuntu@${self.public_ip} -o StrictHostKeyChecking=no -i ${local.pem_file} "kubeadm token create --print-join-command")
      rm -rf ./kubeadm-scripts/step-03-k8s-join.sh
      echo "sudo $join_cmd"  > ./kubeadm-scripts/step-03-k8s-join.sh
    EOT
  }
}

resource "aws_instance" "ec2_instance_worker_node1" {
  depends_on = [
    aws_instance.ec2_instance_control_plane_node
  ]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg_worker.id]
  subnet_id = aws_subnet.this.id
  tags = {
    Name = "worker1"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa_key.private_key_openssh
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    scripts = [
      "./kubeadm-scripts/step-01-k8s-packages-ubuntu.sh",
      "./kubeadm-scripts/step-03-k8s-join.sh",
    ]
  }
}

resource "aws_instance" "ec2_instance_worker_node2" {
  depends_on = [
    aws_instance.ec2_instance_control_plane_node
  ]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg_worker.id]
  subnet_id = aws_subnet.this.id
  tags = {
    Name = "worker2"
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa_key.private_key_openssh
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    scripts = [
      "./kubeadm-scripts/step-01-k8s-packages-ubuntu.sh",
      "./kubeadm-scripts/step-03-k8s-join.sh",
    ]
  }
}
