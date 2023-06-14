# Exercise


1. Check the node list
```
kubectl get nodes
```

##

2. Check the label and taint of the current node
```
kubectl describe nodes |grep -A5 -i label
kubectl describe nodes |grep -i taint
```

##

3. Check the containers running on the CP node

```
kubectl get deployments --all-namespaces
```
```
sudo crictl ps -q | wc -l
```

##

4. Check the running container on the worker node
```
sudo crictl ps -q | wc -l
```

> ERRO[0000] unable to determine image API version: rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial unix /var/run/dockershim.sock: connect: no such file or directory"

If the above error occurs, run the command below and try again
```
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
```

##

5. In the CP terminal, label each CP node and Worker node

```
kubectl label nodes cp status=vip
kubectl label nodes worker status=other
```

##

6. Check the added label
```
kubectl get nodes --show-labels
```

##


7. Deploy the Pod below to the node with label status: vip
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: vip
spec:
  containers:
  - name: vip1
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip2
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip3
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip4
    image: busybox
    args:
    - sleep
    - "1000000"
  nodeSelector:
    status: vip
EOF
```

##

8. Check the containers running on the CP node

```
sudo crictl ps -q | wc -l
```

##

9. Check the running container on the worker node
```
sudo crictl ps -q | wc -l
```
##

10. Pod Delete
```
kubectl delete pod vip
```

##

11. Create the same Pod as the Pod created above, except for the nodeSelector.
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: vip
spec:
  containers:
  - name: vip1
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip2
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip3
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: vip4
    image: busybox
    args:
    - sleep
    - "1000000"
EOF
```

##

12.Check which node the pod was created on
```
kubectl get pod -o wide
```

##

13. Deploy the Pod below to the node with label status: other
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: other
spec:
  containers:
  - name: other1
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: other2
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: other3
    image: busybox
    args:
    - sleep
    - "1000000"
  - name: other4
    image: busybox
    args:
    - sleep
    - "1000000"
  nodeSelector:
    status: other
EOF
```

##

14. Check which node the above Pod was deployed to
```
kubectl get pod -o wide
```
##

15. Pod Delete
```
kubectl delete pod vip other
```
