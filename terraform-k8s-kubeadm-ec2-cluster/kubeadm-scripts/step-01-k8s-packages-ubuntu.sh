# STEP 1 - Prepare all nodes with Kubernetes Packages
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

# Routine pkg update
sudo yum update -y

# Disable swap. Mandatory in order for the kubelet to work properly
sudo swapoff -a
# And then to disable swap on startup
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Setup Container Runtime
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
#
# Starting with the prerequisites
# Forwarding IPv4 and letting iptables see bridged traffic 

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Container Runtime Setup - Install Containerd
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md

# Install containerd
sudo yum install -y containerd

# Generate and save containerd configuration file to its standard location
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to ensure new configuration file usage:
sudo systemctl restart containerd

# Verify containerd is running.
sudo systemctl status containerd

# Installing kubeadm, kubelet and kubectl 
# Follow the Red Hat-based distributions setup tab in the page below
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
