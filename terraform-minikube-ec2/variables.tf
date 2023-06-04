variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "kubeconfig_output_location" {
  type        = string
  description = "KubeConfig file Location"
  default     = "kubeconfig"
}

variable "minikube_instance_name" {
  type        = string
  description = "Minikube EC2 Instance name"
  default     = "minikube-on-ec2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "exposed_ports" {
  type = list(object({
    port     = number
    protocol = string
  }))
  description = "Ports to expose from Minikube EC2 instance"
  default = [{
    port     = 80
    protocol = "tcp"
  }]

  validation {
    condition = var.exposed_ports == null ? true : (alltrue([
      for o in var.exposed_ports : contains(["tcp", "udp", "icmp", "all", "-1"], o.protocol)
    ]))
    error_message = "The exposed_ports[].prococol should one of: tcp, udp, icmp, all, -1."
  }

  validation {
    condition = var.exposed_ports == null ? true : (alltrue([
      for o in var.exposed_ports : can(tonumber(o.port))
    ]))
    error_message = "var.exposed_ports[].port should be a number"
  }
}
