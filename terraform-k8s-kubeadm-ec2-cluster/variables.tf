# variable "my_public_ip" {
#   description = "Enter your public IP. Run 'curl ifconfig.me' is one way to find out."
#   type        = string
# }

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "control_plane_node_tags" {
  description = "Tags for Control Plane node instance"
  type        = map(string)
  default = {
    Name = "k8s-control-plane-node"
  }
}

variable "worker_node_tags" {
  description = "Tags for Control Plane node instance"
  type        = map(string)
  default = {
    Name = "k8s-worker-node"
  }
}

variable "cp_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "sg_worker_node_tags" {
  description = "Tags for Security Group (Worker node)"
  type        = map(string)
  default = {
    Name = "k8s-cluster-worker"
  }
}

variable "sg_control_plane_tags" {
  description = "Tags for Security Group (Control plane node)"
  type        = map(string)
  default = {
    Name = "k8s-cluster-control-plane"
  }
}
