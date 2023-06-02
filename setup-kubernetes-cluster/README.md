# Create lab environment

## Run in Cloud9 
```
git clone https://github.com/bolecodex/k8s.git
cd k8s/setup-kubernetes-cluster
terraform init
terraform apply --auto-approve
```

## Check the created practice environment information

4. Output the information stored in Output
```
terraform output
```

## Install packages in both control plane and worker nodes

```
git clone https://github.com/bolecodex/k8s.git
cd k8s/setup-kubernetes-cluster
chmod +x setup-container.sh
chmod +x setup-kubetools.sh
sudo ./setup-container.sh
```
```
sudo ./setup-kubetools.sh
```

## Initialize in control plane
```
sudo kubeadm init
```
## Join the worker node
```
# Copy te output and execute the "sudo kubeadm join ..." command in work nodes
sudo kubeadm join ...
# if the command is lost, you can create a new one with "kubeadm token create --print-join-command"
```
## Run in control plane
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

kubectl get nodes
kubectl get pods --all-namespaces
```
## Add auto-completion and shortcuts
```
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo alias k=kubectl >> ~/.bashrc
echo export do="--dry-run=client -o yaml"
source ~/.bashrc
```
