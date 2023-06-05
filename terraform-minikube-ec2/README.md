# Creating A Minikube Cluster using Terraform and AWS EC2


### Provisioning the Infrastructure

```bash
terraform init
terraform apply
```

### Connecting to the k8s cluster

You can export the Kubeconfig file using this helper
```bash
terraform output
```
