# Task 1 
Create a Persistent Volume with the name mypv, that uses local host storage and provides 1 GiB of storage. This PV should be accessible from all name spaces.

Create a Persistent Volume claim that requests 100 MiB. 

Run a Pod with the name pv-pod that uses this persistent volume from the "myvol" namespace. 

Use kubectl edit or kubectl patch with recording to change the size of the claim from 100MiB to 200MiB
# Solution
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: manual
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
reclaimPolicy: Delete
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  namespace: myvol
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: pv-pod
  namespace: myvol
spec:
  volumes:
    - name: mypv
      persistentVolumeClaim:
        claimName: mypvc
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: mypv
```
