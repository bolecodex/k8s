# Task 1 
Create a Persistent Volume with the name mypv, that uses local host storage and provides 1 GiB of storage. This PV should be accessible from all name spaces.

Create a Persistent Volume claim that requests 100 MiB. 

Run a Pod with the name pv-pod that uses this persistent volume from the "myvol" namespace. 

Use kubectl edit or kubectl patch with recording to change the size of the claim from 100MiB to 200MiB

# Exercise 8.2. 

>Proceed with the root administrator account
```
sudo -i
```
##

1.NFS server installation
```
sudo apt update && sudo apt install -y nfs-kernel-server
```

##

2. Create a shared directory and create files
```
sudo mkdir /opt/sfw
sudo chmod 1777 /opt/sfw/
sudo bash -c 'echo software > /opt/sfw/hello.txt'
```

##

3. Add the directory created above in the NFS configuration file
```
sudo echo '/opt/sfw/ *(rw,sync,no_root_squash,subtree_check)' > /etc/exports
```


##

4. Reflect NFS Settings
```
sudo exportfs -ra
```

##

5. Go to Worker node and install NFS
```
sudo apt-get -y install nfs-common
```
```
showmount -e k8scp
```
```
sudo mount k8scp : / opt / sfw / mnt
```
```
ls -l /mnt
```

##

6. Go to CP node and create pv
Switch back to your ubuntu account
```
exit
```

```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvvol-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/sfw
    server: k8scp
    readOnly: false
EOF
```

7. Check the generated pv
```
kubectl get pv
```

# Exercise 8.3


1.pvc check
```
kubectl get pvc
```

##

2.pvc creation
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

##

3. Check the created pvc
```
kubectl get pvc
```

##

4.deployment creation
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-nfs
spec:
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        volumeMounts:
        - name: nfs-vol
          mountPath: /opt
        ports:
        - containerPort: 80
          protocol: TCP
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: pvc-one
EOF
```

##

5.Check Pod deployed by Deployment and look up detailed information
```
kubectl get pod
kubectl describe pod <pod name from above>
```

##

6.pvc connection status check
```
kubectl get pvc
```

# Exercise 8.4


1. Delete the previous lab used resources
```
kubectl delete deploy nginx-nfs
kubectl delete pvc pvc-one
kubectl delete pv pvvol-1
```

##

2. Create NS
```
kubectl create ns small
```

##

3. Search detailed information of the NS created above
(Check ResourceQuota, LimitRange settings)
```
kubectl describe ns small
```

##

4.PV and PVC production
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvvol-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/sfw
    server: k8scp
    readOnly: false
EOF
```
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

##

5.ResourceQuota Creation
```
cat <<EOF | kubectl apply -n small -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storagequota
spec:
  hard:
    persistentvolumeclaims: "10"
    requests.storage: "500Mi"
EOF
```

##

6. RQ reflection confirmation
```
kubectl describe ns small
```

##

7.Deployment Creation
```
cat <<EOF | kubectl create -n small -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-nfs
spec:
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        volumeMounts:
        - name: nfs-vol
          mountPath: /opt
        ports:
        - containerPort: 80
          protocol: TCP
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: pvc-one
EOF
```

##

8. Check the created Pod
```
kubectl get pod -n small
kubectl describe pod -n small
```

##

9. RQ reflection confirmation
```
kubectl describe ns small
```

##

10. Create a file in the /otp/sfw directory
```
sudo dd if=/dev/zero of=/opt/sfw/bigfile bs=1M count=300
```

##

11. RQ reflection confirmation
```
kubectl describe ns small
sudo du -h /opt/
```

##

12. Delete existing Deployment, pvc
```
kubectl delete deploy nginx-nfs -n small
kubectl delete pvc pvc-one -n small
```

##

13. RQ reflection confirmation (use amount change)
```
kubectl describe ns small
```

##

14. Check PV status
```
kubectl get pv pvvol-1 -n small
```

##

15.pv delete
```
kubectl delete pv pvvol-1
```

##

16. Recreate pv (set persistentVolumeReclaimPolicy: Delete)
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvvol-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete
  nfs:
    path: /opt/sfw
    server: k8scp
    readOnly: false
EOF
```

##

17.pv's ReclaimPolicy, RQ confirmation
```
kubectl get pv pvvol-1
kubectl describe ns small
```

##

18. PVC production
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

##

19. RQ reflection confirmation
```
kubectl describe ns small
```

##

20.RQ modified (requests.storage value modified to 100Mi)
```
cat <<EOF | kubectl apply -n small -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storagequota
spec:
  hard:
    persistentvolumeclaims: "10"
    requests.storage: "100Mi"
EOF
```

##

21. RQ reflection confirmation
```
kubectl describe ns small
```

##

22.Deployment creation
```
cat <<EOF | kubectl create -n small -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-nfs
spec:
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        volumeMounts:
        - name: nfs-vol
          mountPath: /opt
        ports:
        - containerPort: 80
          protocol: TCP
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: pvc-one
EOF
```

##

23.Check the Pod deployed by the above Deployment
```
kubectl get pods -n small
```

##

24. Delete Deployment, pvc to confirm resource return
```
kubectl -n small delete deploy nginx-nfs
kubectl -n small delete pvc/pvc-one
```

##

Make sure 25.pv is deleted together
```
kubectl get pv
```

##

26.pv event confirmation
```
kubectl describe pv pvvol-1
```

##

Delete 27.pv
```
kubectl delete pv pvvol-1
```

##

28. Create LimitRange
```
cat <<EOF | kubectl -n small apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: storagelimits
spec:
  limits:
  - type: PersistentVolumeClaim
    max:
      storage: 2Gi
    min:
      storage: 1Gi
EOF
```

##

29. RQ, LR reflection confirmation
```
kubectl describe ns small
```

##

Create 30.pv (ReclaimPolicy: Recycle) and confirm
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvvol-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /opt/sfw
    server: k8scp
    readOnly: false
EOF
```
```
kubectl get pv
```

##

Attempt to create 31.pvc (scheduled to fail due to limiting reasons)
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

##

32.RQ modified (requests.storage: "500Mi")
```
cat <<EOF | kubectl apply -n small -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storagequota
spec:
  hard:
    persistentvolumeclaims: "10"
    requests.storage: "500Mi"
EOF
```

##

33. Attempt to regenerate PVC (scheduled to fail due to limiting reasons)
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

##

34.Change LimitRange setting
```
cat <<EOF | kubectl -n small apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: storagelimits
spec:
  limits:
  - type: PersistentVolumeClaim
    max:
      storage: 2Gi
    min:
      storage: 100Mi
EOF
```
##


35.pv, Create Deployment
```
cat <<EOF | kubectl create -n small -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
EOF
```

```
cat <<EOF | kubectl create -n small -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-nfs
spec:
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        volumeMounts:
        - name: nfs-vol
          mountPath: /opt
        ports:
        - containerPort: 80
          protocol: TCP
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: pvc-one
EOF
```


##

34.Check the Pod deployed by Deployment
```
kubectl get pod -n small
```

##

35. Check if the file created on the nfs server is visible
```
kubectl -n small exec deploy/nginx-nfs -- cat /opt/hello.txt
```

##

36.Delete Deployment
```
kubectl delete deploy nginx-nfs -n small
```

##

Check 37.pvc,pv
```
kubectl get pvc -n small
kubectl get pv
```

##

Delete 38.pvc
```
kubectl delete pvc pvc-one -n small
```

##

39.pv status check, event check
```
kubectl get pv
kubectl describe pv pvvol-1
```

##

Delete 40.pv
```
kubectl delete pv pvvol-1
```

##

Delete 41.NS
```
kubectl delete ns small
```
