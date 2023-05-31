# Demo: Backing up the Etcd
```
sudo apt install etcd-client
sudo etcdctl --help; sudo ETCDCTL_API=3 etcdctl --help
ps aux | grep etcd

sudo ETCDCTL_API=3 etcdctl --endpoints=localhost:2379 \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key get / --prefix --keys-only

sudo ETCDCTL_API=3 etcdctl --endpoints=localhost:2379 \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key snapshot save /tmp/etcdbackup.db

sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status /tmp/etcdbackup.db
cp /tmp/etcdbackup.db /tmp/etcdbackup.db.2
```
# Task
kubectl delete --all deploy
cd /etc/kubernetes/manifests/
sudo mv * .. # this will stop all running pods
sudo crictl ps
sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcdbackup.db --data-dir /var/lib/etcd-backup
sudo ls -l /var/lib/etcd-backup/
sudo vi /etc/kubernetes/etcd.yaml # change etcd-data HostPath volume to /var/lib/etcd-backup
sudo mv ../*.yaml .
sudo crictl ps # should show all resources
kubectl get deploy -A

# Exercise 4.1 - etcd database backup

1. etcd daemon search data directory

```
sudo grep data-dir /etc/kubernetes/manifests/etcd.yaml
```
> Find the data-dir string in the /etc/kubernetes/manifests/etcd.yaml file and output it


##

2. etcd pod name check

```
kubectl -n kube-system get pod
```

##

3. etcd pod connection

```
kubectl -n kube-system exec -it <etcd pod name> -- sh
```

##

4. Retrieve certificate and key files for tls use

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

6. Check DB status using Loopback IP, port 2379

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
sudo cp -r /etc/kubernetes/pki/etcd $HOME/backup/
```

##

If you proceed with the restoration operation, the cluster may not be available if an error occurs during restoration, so it is recommended to try restoration after the final practice.

Please refer to the link below for the detailed restoration process.

https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster

##
