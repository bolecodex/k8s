# STEP 4 - Initialize and setup Control Plane Node
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node
#
# IMPORTANT - This runs on the Control Plane node
# Output of each command is given in the curly braces to compare with your output and detect issues in case of mismatch
#
sudo hostnamectl set-hostname cp
sudo kubeadm init --pod-network-cidr 192.168.0.0/16

# Save 'kubeadm join ...' command from the above output to run in next step on the Worker Nodes
# Or get it by running 'kubeadm token create --print-join-command' on the Control Plane Node later

# Setup cluster config following the previous command output
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install the Calico Network Add-On on the Control Plane node
# Reference: https://docs.tigera.io/calico/3.25/getting-started/kubernetes/quickstart
# For other Network options, see
# https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Install the Tigera Calico operator and custom resource definitions.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

# Install Calico by creating the necessary custom resource. 
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

# FYI, install the calicoctl CLI tool to manage Calico resources and perform administrative functions following the link:
# https://docs.tigera.io/calico/3.25/operations/calicoctl/install

# Test Control Plane node. Expected to be in Ready state this time
kubectl get nodes
