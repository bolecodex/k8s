# Execute the following in all nodes
git clone https://github.com/bolecodex/k8s.git
cd k8s/setup-kubernetes-cluster
chmod +x setup-container.sh
chmod +x setup-kubetools-ubuntu.sh
./setup-container.sh
./setup-kubetools-ubuntu.sh

# Execute the following in control node
sudo kubeadm init

# Copy te output and execute the "sudo kubeadm join ..." command in work nodes
# if the command is lost, you can create a new one with "kubeadm token create --print-join-command"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
kubectl get pods --all-namespaces

kubectl cluster-info
kubectl get nodes

source <(kubectl completion bash)
