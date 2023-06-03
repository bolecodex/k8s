# Demo Setting up Rook
```
# On a 3 node cluster, ensure each node has a /dev/sdb device
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
# wait 1 minute
kubectl create -f cluster.yaml
kubectl -n rook-ceph get pods # ensure that the osd pod, as well as the mon pod(s) are up, will take about 4 minutes
kubectl create -f storageclass.yaml # from kcna git repo, or as in Ceph Doc
kubectl create -f toolbox.yaml # will install rook-ceph-tools pod
kubectl -n rook-ceph exec -it rook-ceph-tools* -- ceph status # ignore the health warn
kubectl get pv,pvc
# Edit wordpress.yaml and mysql.yaml and set storage request to 2 GB!
kubectl create -f wordpress.yaml -f mysql.yaml
kubectl get pv,pvc
kubectl exec -it wordpress* -- bash -c "mount | grep rbd"
ceph status
ceph osd status
# Run ceph status and ceph osd status on the Ceph management pod to verify activity
```