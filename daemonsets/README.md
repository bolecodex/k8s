# Demo: Creating a DaemonSet
```
kubectl create deploy daemondemo --image=nginx --dry-run=client -o=yaml > daemondemo.yaml
Change kind: to kind: DaemonSet
Delete replicas, strategy and status
kubectl create -f daemondemo.yaml
kubectl get daemonset
```

# Exercise 7.2


1.Daemonset creation
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-one
spec:
  selector:
    matchLabels:
      system: DaemonSetOne
  template:
    metadata:
      labels:
        system: DaemonSetOne
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.1
        ports:
        - containerPort: 80
EOF
```

##

2.Deamonset deployment check
```
kubectl get ds
kubectl get pod
```

##

3. Check the img running on the pod (used in the next section)
```
kubectl describe pod <pod name from above> | grep Image:
```


# Exercise 7.3


1. Check Daemonset's Update method created in the previous section
```
kubectl get ds ds-one -o yaml | grep -A 4 Strategy
```

##

2. Edit editing with the edit command
```
kubectl edit ds ds-one
```
Modify type to OnDelete

```
updateStrategy:
  rollingUpdate:
 maxUnavailable: 1
  type: OnDelete
```

##

3. Updating the image with the set command
```
kubectl set image ds ds-one nginx=nginx:1.16.1-alpine
```

##

4. Check the image of the pod identified in the previous section (not updated)
```
kubectl describe pod <pod name from previous section> | grep Image:
```

##

5.Delete the pod and check the image of the redeployed pod
```
kubectl delete pod <the Pod Name from the previous section>
```

```
kubectl get pod
kubectl describe pod <pod name from above> | grep Image:
```

##

6. Check the image of the old Pod
```
kubectl describe pod <Old pod name> | grep Image:
```

##

7. Check DaemonSet's change history
```
kubectl rollout history ds ds-one
```

##

8. Confirm setting by designating each revision number
```
kubectl rollout history ds ds-one --revision=1
kubectl rollout history ds ds-one --revision=2
```

##

Rollback to previous version via 9.undo command
```
kubectl rollout undo ds ds-one --to-revision=1
```

##

10.Check the image after checking the Pod name
```
kubectl get pod
kubectl describe pod <pod name from above> | grep Image:
```

##

11.Delete the above pod and check the image of the redeployed pod
```
kubectl delete pod <pod name from above>
```

```
kubectl get pod
```

```
kubectl describe pod <new pod name from above> | grep Image:
```

##

12.Deamonset information confirmation
```
kubectl describe ds | grep Image:
```

##

13. Daemonset deployment with the update method set to RollingUpdate with the command below
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-two
spec:
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      system: DaemonSetOne
  template:
    metadata:
      labels:
        system: DaemonSetOne
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.1
        ports:
        - containerPort: 80
EOF
```

##

14.Pod check
```
kubectl get pod
```

##

15. Check the image of the Pod
```
kubectl describe pod <pod name deployed above> | grep Image:
```

##

16.Daemonset modification
```
kubectl edit ds ds-two --record
```
image correction
```
  iamge: nginx:1.16.1-alpine
```  

##

17. Check Daemonset and Pod
```
kubectl get ds ds-two
kubectl get pod
```

##

18. Check the image of the Pod
```
kubectl describe pod <pod name from above> | grep Image:
```

##

19. Check rollout status, history
```
kubectl rollout status ds ds-two
kubectl rollout history ds ds-two
```

##

20. Check the status of the saved Revision 2
```
kubectl rollout history ds ds-two --revision=2
```

##

21. Delete Daemonset
```
kubectl delete ds ds-one ds-two
```
