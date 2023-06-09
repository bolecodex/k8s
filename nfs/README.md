# Demo: Configuring a Storage Provisioner
```
# Configure Security Group of control plane to allow all traffic
# Run on control plane: 
sudo apt install nfs-server -y
mkdir /nfsexport
echo "/nfsexport *(rw,no_root_squash)" > /etc/exports
sudo systemctl restart nfs-server
showmount -e localhost
# -------------------
# Run on worker nodes:
sudo apt install nfs-client 
showmount -e <private IP address of control plane node>
# -------------------
# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Add helm repo and install the package
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=172.31.10.75 --set nfs.path=/nfsexport -n kube-system 
kubectl get pods -n kube-system 
kubectl get pv
kubectl apply -f nfs-provisioner-pvc-test.yaml
# Verify the PVC is created and bound to an automatically created PV
kubectl get pvc,pv
# Create any Pod that mounts the PVC storage and verify data end up in the NFS share
ls /nfsexport/
```