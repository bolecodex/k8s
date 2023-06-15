# Demo 1: Allow user pods to also run on the control node
```
kubectl taint node control node-role.kubernetes.io/control-plane:NoSchedule-
# Another option:
kubectl edit node control
# delete three lines of taint
kubectl deploy taintdeploy --image=nginx replicas=3
kubectl get pod -o wide | grep taintdeploy 
```

# Demo 2: Taint and toleration
```
kubectl taint nodes <worker node name>1 storage=ssd:NoSchedule
kubectl describe nodes <worker node name>1
kubectl create deployment nginx-taint --image=nginx
kubectl scale deployment nginx-taint –replicas=3
kubectl get pods –o wide # will show that pods are all on worker2
kubectl create –f taint-toleration.yaml
```

# Exercise


1. Deployment creation
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taint-deployment
spec:
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name:  nginx
        image: nginx:1.20.1
        ports:
        - containerPort: 80
EOF
```

##

2. Check which node the Pod created by the above Deployment is deployed to
```
kubectl get pod -o wide
```

##

3. Delete Deployment
```
kubectl delete deployment taint-deployment
```

##

4. Set up a taint on the Worker node
```
kubectl taint nodes <worker node name> status=unstable:PreferNoSchedule
```

##

5. Check the taint on the worker node
```
kubectl describe node <worker node name> | grep Taint
```

##

6. Delete Deployment
```
kubectl delete deployment taint-deployment
```

##

7. Delete the taint set in the worker node
```
kubectl taint nodes <worker node name> status-
```

##

8. Check the taint on the worker node
```
kubectl describe node <worker node name> | grep Taint
```






The following contents are just repeating.

##

9. Set a new taint on the Worker node
```
kubectl taint nodes <worker node name> operation=upgrading:NoSchedule
```

##

10. Check the taint on the worker node
```
kubectl describe node <worker node name> | grep Taint
```

##

11. Create Deployment again
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taint-deployment
spec:
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name:  nginx
        image: nginx:1.20.1
        ports:
        - containerPort: 80
EOF
```

##

12. Check which node the Pod created by the above Deployment is deployed to
```
kubectl get pod -o wide
```

##

13. Delete Deployment
```
kubectl delete deployment taint-deployment
```

##

14. Delete the taint set in the worker node
```
kubectl taint nodes <worker node name> operation-
```

##

15. Create Deployment again
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taint-deployment
spec:
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name:  nginx
        image: nginx:1.20.1
        ports:
        - containerPort: 80
EOF
```

##

16. Check which node the Pod created by the above Deployment is deployed to
```
kubectl get pod -o wide
```

##

17. Set the taint on the worker node
```
kubectl taint nodes <worker node name> performance=slow-disk:NoExecute
```

##

18. Confirm that the Pods in the Worker node have been moved to CP
```
kubectl get pod -o wide -w
```

##

19. Delete the taint set in the worker node
```
kubectl taint nodes <worker node name> performance-
```

##

20. Check again whether the Pods in the CP have been moved to the Worker node (not moved)
```
kubectl get pod -o wide
```

##

21. Delete Deployment
```
kubectl delete deployment taint-deployment
```
