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
  region = "us-east-1"
}

# Defile any local vars
locals {
  pem_file     = "~/.ssh/k8s-kp.pem"
  key_name     = "k8s-kp"
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
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "TCP"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg_worker.id]
  }
  ingress {
    description = "TCP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "TCP"
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg_worker.id]
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
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
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

resource "aws_security_group_rule" "ec2_sg_worker_allow_cp_sg" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg_worker.id
  source_security_group_id = aws_security_group.ec2_sg_control_plane.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2_instance_control_plane_node" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg_control_plane.id]
  tags                   = var.control_plane_node_tags

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.rsa_key.private_key_openssh
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    scripts = [
      "./kubeadm-scripts/step-01-k8s-packages.sh",
      "./kubeadm-scripts/step-02-k8s-cp-init.sh",
    ]
  }
  provisioner "local-exec" {
    command = <<-EOT
      join_cmd=$(ssh ec2-user@${self.public_ip} -o StrictHostKeyChecking=no -i ${local.pem_file} "kubeadm token create --print-join-command")
      rm -rf ./kubeadm-scripts/step-03-k8s-join.sh
      echo "sudo $join_cmd"  > ./kubeadm-scripts/step-03-k8s-join.sh
    EOT
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

resource "aws_instance" "ec2_instance_worker_node" {
  depends_on = [
    aws_instance.ec2_instance_control_plane_node
  ]
  count                  = var.worker_node_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg_worker.id]

  tags = var.worker_node_tags

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.rsa_key.private_key_openssh
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    scripts = [
      "./kubeadm-scripts/step-01-k8s-packages.sh",
      "./kubeadm-scripts/step-03-k8s-join.sh",
    ]
  }
}
