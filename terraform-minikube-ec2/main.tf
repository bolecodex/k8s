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

resource "aws_key_pair" "aws_keypair" {
  public_key = tls_private_key.private_key.public_key_openssh
  key_name   = "minikube"
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

resource "aws_eip" "instance_elastic_ip" {}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

locals {
  setup_minikube_command = <<EOT
/home/ubuntu/setup_minikube.sh \
--elastic-ip ${aws_eip.instance_elastic_ip.public_ip} 
EOT
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

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup_minikube.sh"
    destination = "/home/ubuntu/setup_minikube.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/setup_minikube.sh",
      local.setup_minikube_command
    ]
  }
}

resource "null_resource" "download_kubeconfig" {
  depends_on = [
    aws_instance.minikube_instance
  ]
  triggers = {
    "timestamp" = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/download_kubeconfig.sh \"$PRIVATE_KEY\" ubuntu ${aws_eip.instance_elastic_ip.public_ip} ${var.kubeconfig_output_location}"
    environment = {
      PRIVATE_KEY = tls_private_key.private_key.private_key_pem
    }
  }
}

resource "aws_eip_association" "minikube_eip_assoc" {
  instance_id   = aws_instance.minikube_instance.id
  allocation_id = aws_eip.instance_elastic_ip.id
}
