# Exercise


1. Replicaset confirmation
```
kubectl get rs
```

##

2. Deploy rs with the command below
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-one
spec:
  replicas: 2
  selector:
    matchLabels:
      system: ReplicaOne
  template:
    metadata:
      labels:
        system: ReplicaOne
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.1
        ports:
        - containerPort: 80
EOF
```

##

3. Check detailed information
```
kubectl describe rs rs-one
```

##

4. Pod check
```
kubectl get pods
```

##

5. Delete rs but not delete pod(pod will stay running)
```
kubectl delete rs rs-one --cascade=orphan
```

##

6. Check RS and Pod again
```
kubectl get rs
kubectl get pod
```

##

7. Redistributed rs in 2
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-one
spec:
  replicas: 2
  selector:
    matchLabels:
      system: ReplicaOne
  template:
    metadata:
      labels:
        system: ReplicaOne
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.1
        ports:
        - containerPort: 80
EOF
```

##

8. Recheck
```
kubectl get rs
kubectl get pod
```

##

9. Modify existing resources with the edit command
```
kubectl edit pod <pod name from above>
```
modified to
```
labels:
  system: IsolatedPod
```

##

10. Check RS again
```
kubectl get rs
```

##

11. Pod identification (labels)
```
kubectl get pod -L system
```

##

12. Delete RS
```
kubectl delete rs rs-one
```

##

13. Pod check
```
kubectl get pods
```

##

14. Delete the pod separated from RS
```
kubectl delete pod -l system=IsolatedPod
```
