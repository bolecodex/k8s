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

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

locals {
  pem_file     = "~/.ssh/minikube.pem"
  key_name     = "minikube"
}

resource "aws_key_pair" "aws_keypair" {
  public_key = tls_private_key.private_key.public_key_openssh
  key_name   = local.key_name
  
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ${local.pem_file}
      echo '${tls_private_key.private_key.private_key_pem}' > ${local.pem_file}
      chmod 400 ${local.pem_file}
      ls -l ${local.pem_file} > /tmp/out
    EOT
  }
}

resource "aws_security_group" "allow_kube_api_server" {
  name        = "${var.minikube_instance_name}-allow-kube-api-server"
  description = "Allow incoming K8S API Server traffic"

  ingress = [
    {
      description      = "allow ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "allow api server"
      from_port        = 8443
      to_port          = 8443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "allow all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "allow_kube_api_server"
  }
}

resource "aws_security_group" "allow_additional_exposed_ports" {
  name        = "${var.minikube_instance_name}-allow-additional-exposed-ports"
  description = "Allow exposed ports from services"
  ingress = [
    for exposed_port in var.exposed_ports : {
      description      = "allow ports ${exposed_port.port}"
      from_port        = exposed_port.port
      to_port          = exposed_port.port
      protocol         = exposed_port.protocol
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}


resource "aws_instance" "minikube_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = data.aws_ec2_instance_type.this.id
  key_name      = aws_key_pair.aws_keypair.key_name
  security_groups = [
    aws_security_group.allow_kube_api_server.name,
    aws_security_group.allow_additional_exposed_ports.name
  ]

  tags = {
    Name = var.minikube_instance_name
  }

  user_data = <<EOF
#!/bin/bash
ARCH=$(arch)
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

if [ $ARCH = "x86_64" ]
then
  echo executing on $ARCH
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl

  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
fi

if [ $ARCH = "aarch64" ]
then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
  sudo install minikube-linux-arm64 /usr/local/bin/minikube
  sudo snap install kubectl --classic 
fi

echo the script is now ready
echo manually run minikube start --vm-driver=docker --cni=calico to start minikube

sudo usermod -aG docker $USER
newgrp docker
EOF

}
