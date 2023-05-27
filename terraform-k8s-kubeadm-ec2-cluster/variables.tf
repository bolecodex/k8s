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

variable "ami_id" {
  description = "AMI used for the EC2 instances"
  type        = string
  default     = "ami-0cff7528ff583bf9a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
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
