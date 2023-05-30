# Exercise 7.1


1.Replicaset confirmation
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

4.Pod check
```
kubectl get pods
```

##

5.rs delete (pod not deleted option added)
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

rs redistributed in 7.2
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

Modify existing resources with the 9.edit command
```
kubectl edit pod <pod name from above>
```

```
labels:
  system: IsolatedPod
```
modified with

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

12.RS Delete
```
kubectl delete rs rs-one
```

##

13.Pod check
```
kubectl get pods
```

##

14.Delete the pod separated from RS
```
kubectl delete pod -l system=IsolatedPod
```