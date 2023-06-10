# Demo: Configuring a Storage Provisioner

## 1. Configure Security Group of cp to allow all traffic

## 2. Run on control plane to install nfs server
```
sudo apt install nfs-server -y
sudo mkdir /nfsexport
sudo vim /etc/exports
# Add line: /nfsexport *(rw,no_root_squash)
sudo systemctl restart nfs-server
showmount -e localhost
```

## 3. Run on worker nodes rto install nfs client
```
sudo apt install nfs-client 
showmount -e <private IP address of control plane node> 
# private IP address can be found in EC2 service
```
## 4. Install helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
## 5. Add helm repo and install the package
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=172.31.10.75 --set nfs.path=/nfsexport -n kube-system 
```
## 6. Verify the PVC is created and bound to an automatically created PV
```
kubectl get pods -n kube-system 
kubectl get pv
kubectl apply -f nfs-provisioner-pvc-test.yaml
kubectl get pvc,pv
ls /nfsexport/
```
## 7. Create any Pod that mounts the PVC storage and verify data end up in the NFS share
```
```
