output "minikube_public_ip" {
  description = "MiniKube instance public ip address"
  value       = "ssh -i ~/.ssh/minikube.pem ubuntu@${aws_instance.minikube_instance.public_dns}"
}
