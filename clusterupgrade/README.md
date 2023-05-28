# Exercise 4.1 - Basic Node Maintenance

> Back up the etcd database 

1.Search the etcd daemon data directory 

``` 
sudo grep data-dir /etc/kubernetes/manifests/etcd.yaml 
``` 
> /etc/kubernetes/manifests/etcd.yaml Find the data-dir string in the file and output it 


## 

2.etcd Check pod name 

``` 
kubectl -n kube-system get pod 
``` 

## 

3.etcd pod connection 

``` 
kubectl -n kube-system exec -it <etcd pod name> -- sh 
``` 

## 

Retrieve certificate and key files to use 4.tls 

``` 
cd /etc/kubernetes/pki/etcd 
echo * 
``` 

## 

Disconnect 5.Pod 

``` `` 
exit 
``` 

##

6.Check DB status using loopback IP, port 2379 

``` 
kubectl -n kube-system exec -it etcd-cp -- sh \ 
-c "ETCDCTL_API=3 \ 
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ ca.crt \ 
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \ 
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \ 
etcdctl endpoint health" 
``` 

## 

7. Check the number of DBs in the cluster 

``` 
kubectl -n kube-system exec -it etcd-cp -- sh \ 
-c "ETCDCTL_API=3 \ 
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \ 
ETCDCTL_CERT=/etc/kubernetes/pki/ etcd/server.crt \ 
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \ 
etcdctl --endpoints=https://127.0.0.1:2379 member list" 
``` 

##

8. Output in tabular format using -w option 

``` 
kubectl -n kube-system exec -it etcd-cp -- sh \ 
-c "ETCDCTL_API=3 \ 
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca .crt \ 
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \ 
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \ 
etcdctl --endpoints=https://127.0.0.1:2379 member list - w table" 
``` 

## 

9.Save the snapshot to container data directory /var/lib/etcd 

``` 
kubectl -n kube-system exec -it etcd-cp -- sh \ 
-c "ETCDCTL_API=3 \ 
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \ 
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \ 
etcdctl --endpoints=https://127.0.0.1:2379 snapshot save /var/lib /etcd/snapshot.db " 
```















``` 
sudo apt update 
``` 


2.Check the list of available kubeadm packages (in madison form) 

``` 
sudo apt-cache madison kubeadm 
``` 

## 

3.kubeadm hold uninstall, install version 1.25.1 

`` ` 
sudo apt-mark unhold kubeadm 
sudo apt-get install -y kubeadm=1.25.1-00 
``` 

## 

4.Kubeadm hold again 

``` 
sudo apt-mark hold kubeadm 
``` 

## 

5.kubeadm version check 

``` 
sudo kubeadm version 
``` 

## 

6.cp Remove scheduling (pod deployment) functionality to nodes, (to update cp nodes, you must first remove as many pods as possible) ``` kubectl 

drain 
cp - -ignore-daemonsets 
``` 

## 

7.kubeadm Check upgrade plan

``` 
``` 

## 

8. Run the kubeadm upgrade (type y when prompted to continue the upgrade) 

``` 
sudo kubeadm upgrade apply v1.25.1 
``` 

## 

9.Check node status. (Confirm CP schedule is disabled) 

``` 
kubectl get nodes 
``` 

## 

10.kubelet, kubectl unhold 

``` 
sudo apt-mark unhold kubelet kubectl 
``` 

## 

Install kubelet and kubectl according to the 11.kubeadm version 

``` `` 
sudo apt-get install -y kubelet=1.25.1-00 kubectl=1.25.1-00 
``` 

## 

12.kubelet, kubectl hold 

``` 
sudo apt-mark hold kubelet kubectl 
``` 

## 

13 .daemon restart 

``` 
sudo systemctl restart kubelet

## 

14.Check the new CP node version 

``` 
kubectl get nodes 
``` 

## 

15.Configure the scheduler to use CP again 

``` 
kubectl uncordon cp 
``` 

## 

16.Check the CP node Ready state 

``` 
kubectl get nodes 
``` 

## 

17.Uninstall kubeadm hold from Worker node, install as version 1.24.1 ``` 

sudo 
apt-mark unhold kubeadm 
sudo apt-get install -y kubeadm=1.25.1-00 
``` 

# #

18.Kubeadm hold again 

``` 
sudo apt-mark hold kubeadm 
``` 

## 

19.Add option to ignore daemonsets from CP node to worker node 

``` 
kubectl drain worker --ignore-daemonsets 
``` 

# #

20.Upgrade on worker node 

sudo kubeadm upgrade node 
``` 

## 

21.kubelet, kubectl unhold 

``` 
sudo apt-mark unhold kubelet kubectl 
``` 

## 

Install kubelet and kubectl according to the 22.kubeadm version 

``` 
sudo apt-get install -y kubelet=1.25.1-00 kubectl=1.25.1-00 
``` 

## 

23.kubelet, kubectl hold 

``` 
sudo apt-mark hold kubelet kubectl 
``` 

## 

24.daemon Restart 

``` 
sudo systemctl daemon-reload 
sudo systemctl restart kubelet 
``` 

## 

25.CP Check worker node status on nodes 

``` 
kubectl get nodes 
``` 

##

26. Configure the scheduler to use workers again 

```


