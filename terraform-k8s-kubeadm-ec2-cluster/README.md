# Creating A Kubernetes Cluster with Kubeadm using Terraform and AWS EC2
## Run in AWS Cloud9 
```
git clone https://github.com/bolecodex/k8s.git
cd k8s/terraform-k8s-kubeadm-ec2-cluster
terraform init
terraform apply --auto-approve
# Wait for around 4 minutes
```
## SSH into the control plane and worker node
```
cd k8s/terraform-k8s-kubeadm-ec2-cluster
ssh -i ./k8s-kp.pem ubuntu@ec2-<ip-address>.compute-1.amazonaws.com
```

## Add auto-completion and shortcuts
```
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo alias k=kubectl >> ~/.bashrc
echo export do="--dry-run=client -o yaml" >> ~/.bashrc
source ~/.bashrc
PS1="\[\033[01;32m\]cp\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)" 2>/dev/null) $ "
# rm -rf * # Optional
```

## Use SSH Tools
```
# Download and install WindTerm https://github.com/kingToolbox/WindTerm
```

## Cleanup
```
cd k8s/terraform-k8s-kubeadm-ec2-cluster
terraform destroy --auto-approve
# Wait for around 3 minutes
```

For CentOs version, please refer to code repo of the **[The AWS Way — IaC in Action — Creating A Kubernetes Cluster with Kubeadm using Terraform and AWS EC2](https://jdluther.medium.com/the-aws-way-iac-in-action-creating-a-kubernetes-cluster-with-kubeadm-using-terraform-and-aws-8227203e000e)** blog.

