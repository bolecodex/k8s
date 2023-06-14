# Exercise 1


1. Attempt to create Deployment (scheduled to fail)
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-one
  labels:
    system: secondary
  namespace: accounting
spec:
  selector:
    matchLabels:
      system: secondary
  replicas: 2
  template:
    metadata:
      labels:
        system: secondary
    spec:
      containers:
      - image: nginx:1.20.1
        imagePullPolicy: Always
        name: nginx
        ports:
        - containerPort: 8080
          protocol: TCP
      nodeSelector:
        system: secondOne
EOF
```

##

2. Check the node's label
```
kubectl get node --show-labels
```

##

3. NS generation
```
kubectl create ns accounting
```

##

4. Deployment Creation
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-one
  labels:
    system: secondary
  namespace: accounting
spec:
  selector:
    matchLabels:
      system: secondary
  replicas: 2
  template:
    metadata:
      labels:
        system: secondary
    spec:
      containers:
      - image: nginx:1.20.1
        imagePullPolicy: Always
        name: nginx
        ports:
        - containerPort: 8080
          protocol: TCP
      nodeSelector:
        system: secondOne
EOF
```

##

5. Pod check
```
kubectl -n accounting get pod
```

##

6. Query detailed information to determine the cause of the pod's status
```
kubectl -n accounting describe pod <pod name identified above>
```

##

7. Label the Worker node
```
kubectl label node worker system=secondOne
```

##

8. Check the node's label
```
kubectl get node --show-labels
```

##

9. Check Pod Status
```
kubectl -n accounting get pod
```

##

10. Search for pods with a label of system=secondOndary
```
kubectl get pods -l system=secondary --all-namespaces
```

##

11. Service Creation
```
kubectl -n accounting expose deployment nginx-one
```

##

12. endpoint check
```
kubectl -n accounting get ep nginx-one
```

##

13. Attempt access to port 8080 with endpoint
```
curl <IP verified above>:8080
```
```
curl <IP verified above>:80
```

##

14. Delete Deployment
```
kubectl -n accounting delete deployment nginx-one
```

##

15. Modify the port setting to 80 and create it again
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-one
  labels:
    system: secondary
  namespace: accounting
spec:
  selector:
    matchLabels:
      system: secondary
  replicas: 2
  template:
    metadata:
      labels:
        system: secondary
    spec:
      containers:
      - image: nginx:1.20.1
        imagePullPolicy: Always
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
      nodeSelector:
        system: secondOne
EOF
```

# Exercise 2


1. Create NodePort type Service
```
kubectl -n accounting expose deployment nginx-one --type=NodePort --name=service-lab
```

##

2. View detailed service information
```
kubectl -n accounting describe services
```

##

3. Check cluster information
```
kubectl cluster-info
```

##

4. Confirm by assigning node ports with the curl command
```
curl http://k8scp:<nodeport checked above>
```

##

5. Check the public IP of the node
```
curl ifconfig.io
```

# Exercise 3


1. Delete all pods with label system=secondary
```
kubectl delete pod -l system=secondary --all-namespaces
```

##

2. Accounting NS Pod inquiry
```
kubectl -n accounting get pod
```

##

3. Accounting NS deployment label lookup
```
kubectl -n accounting get deploy --show-labels
```

##

4. Delete the Deployment by deleting the label
```
kubectl -n accounting delete deploy -l system=secondary
```

##

5. Delete the system label on the worker node
```
kubectl label node worker system-
```

##

6. Delete resource
```
kubectl delete deploy nginx
kubectl delete svc nginx
kubectl delete svc nginx-one -n accounting
kubectl delete ns accounting
```
