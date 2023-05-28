# Exercise 4.1 - Basic Node Maintenance

> etcd database backup

1.etcd daemon search data directory

```
sudo grep data-dir /etc/kubernetes/manifests/etcd.yaml
```
> Find the data-dir string in the /etc/kubernetes/manifests/etcd.yaml file and output it


##

2.etcd pod name check

```
kubectl -n kube-system get pod
```

##

3.etcd pod connection

```
kubectl -n kube-system exec -it <etcd pod name> -- sh
```

##

Retrieve certificate and key files for 4.tls use

```
cd /etc/kubernetes/pki/etcd
echo *
```

##

5. Disconnect pod

```
exit
```

##

6.Check DB status using Loopback IP, port 2379

```
kubectl -n kube-system exec -it etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
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
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 member list"
```

##

8. Output in tabular format using the -w option

```
kubectl -n kube-system exec -it etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 member list -w table"
```

##

9. Save the snapshot to the container data directory /var/lib/etcd

```
kubectl -n kube-system exec -it etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 snapshot save /var/lib/etcd/snapshot.db "
```

##

10. Check the snapshot

```
sudo ls -l /var/lib/etcd/
```

##

11. Snapshot Backup

```
mkdir $HOME/backup
sudo cp /var/lib/etcd/snapshot.db $HOME/backup/snapshot.db-$(date +%m-%d-%y)
sudo cp /root/kubeadm-config.yaml $HOME/backup/
sudo cp -r /etc/kubernetes/pki/etcd $HOME/backup/
```

##

If you proceed with the restoration operation, the cluster may not be available if an error occurs during restoration, so it is recommended to try restoration after the final practice.

Please refer to the link below for the detailed restoration process.

https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster

##

##

> Cluster upgrade

1. apt update

```
sudo apt update
```

##

2. Check the list of available kubeadm packages (in madison form)

```
sudo apt-cache madison kubeadm
```

##

3.kubeadm hold removed, installed with version 1.25.1

```
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.25.1-00
```

##

4. hold kubeadm again

```
sudo apt-mark hold kubeadm
```

##

5. Check the kubeadm version

```
sudo kubeadm version
```

##

6. Remove scheduling (pod deployment) functionality to cp nodes, (to update cp nodes, you must first remove as many pods as possible).

```
kubectl drain cp --ignore-daemonsets
```

##

7.kubeadm Check upgrade plan

```
sudo kubeadm upgrade plan
```

##

8. Run kubeadm upgrade (enter y when prompted to continue upgrading)

```
sudo kubeadm upgrade apply v1.25.1
```

##

9. Check node status. (Check Disable CP Schedule)

```
kubectl get nodes
```

##

10.kubelet, kubectl 언포드

```
sudo apt-get unhold kubelet kubectl
```

##

11.Install kubelet and kubectl according to the kubeadm version

```
sudo apt-get install -y cube=1.25.1-00 cubectl=1.25.1-00
```

##

12. kubelet, kubectl hold

```
sudo apt-get mark hold kubelet kubectl
```

##

13. Restart the daemon

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

##

14. Check CP node new version

```
kubectl get nodes
```

##

15. Re-enable scheduler to use CP

```
kubectl uncordon cp
```

##

16. Check CP node Ready status

```
kubectl get nodes
```

##

17. Remove kubeadm hold from Worker node, install with version 1.24.1

```
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.25.1-00
```

##

18. Hold kubeadm again

```
sudo apt-mark hold kubeadm
```

##

19. Add option to ignore daemonset from CP node to worker node

```
kubectl drain worker --ignore-daemonsets
```

##

20.Upgrade on worker node

```
sudo kubeadm upgrade node
```

##

21. kubelet, kubectl 언포드

```
sudo apt-get unhold kubelet kubectl
```

##

22.Install kubelet and kubectl according to the kubeadm version

```
sudo apt-get install -y cube=1.25.1-00 cubectl=1.25.1-00
```

##

23. kubelet, kubectl hold

```
sudo apt-get mark hold kubelet kubectl
```

##

24. Restart the daemon

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

##

25. Check worker node status on CP node

```
kubectl get nodes
```

##

26. Set the scheduler to use the worker again

```
kubectl uncordon worker
```

##

27.Check node's Ready status and version

```
kubectl get nodes
```
