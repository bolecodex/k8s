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
helm version
```
## 5. Add helm repo and install the package
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
# Remember to replace the <private IP address of control plane node> 
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=<private IP address of control plane node>  --set nfs.path=/nfsexport -n kube-system 
```
## 6. Verify the nfs provisioner installed
```
kubectl get pods -n kube-system 
```
## 7. Create any Pod that mounts the PVC storage and verify data end up in the NFS share
```
kubectl get pvc,pv
vim nfs-pvc-pv-pod.yaml # Remember to change <private IP address of control plane node> 
kubectl apply -f nfs-pvc-pv-pod.yaml
kubectl get pvc,pv
ls /nfsexport/
```
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nfs-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /nfsexport
    server: <private IP address of control plane node> 
    readOnly: false
---
kind: Pod
apiVersion: v1
metadata:
   name: nfs-pv-pod
spec:
  volumes:
    - name: nfs-pv
      persistentVolumeClaim:
        claimName: nfs-pv-claim
  containers:
    - name: nfs-client1
      image: centos:7
      command:
        - sleep
        - "3600"
      volumeMounts:
        - mountPath: "/nfsshare"
          name: nfs-pv
    - name: nfs-client2
      image: centos:7
      command:
        - sleep
        - "3600"
      volumeMounts:
        - mountPath: "/nfsshare"
          name: nfs-pv
```
