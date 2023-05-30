# Task 1
Create a pod with the name task6pod that runs Busybox with a command that writes "hello from the cluster" to a file with the name /messages/index.html

Configure this pod with an emptydir type shared volume that is mounted on the directory /messages

Add a sidecar container to this pod, that runs nginx and mounts the shared volume on /usr/lib/nginx/html/

Expose the Pod in such a way that users can access the file presented by the Nginx webserver by addressing a port that is externally exposed on your Kubernetes nodes

# Exercise 13.1


1. Check the kubelet log
```
journalctl -u kubelet |less
```

##

2.Check API server log location
```
sudo find / -name "*apiserver*log"
```

##

3. Check log file contents
```
sudo less <file name identified above>
```

##

4. Check the list of container log files
```
sudo ls /var/log/containers/
```

##

5. Check the list of pod log files on the CP node
```
sudo ls /var/log/pods/
```


# Exercise 13.2


1. Check all currently deployed Pods
```
kubectl get po --all-namespaces
```

##

2.Check API server log
```
kubectl -n kube system logs kube apiserver-cp
```

##

3. Check the identity of the kube-apiserver-cp container running on the CP node
```
sudo crictl ps --name=kube-apiserver
```

##

4. Check the log path of the container above
```
sudo crictl inspect -o go-template --template '{{.status.logPath}}' $(sudo crictl ps --name=kube-apiserver -q)
```

##

5. Check the log of the container
```
sudo cat $(sudo crictl inspect -o go-template --template '{{.status.logPath}}' $(sudo crictl ps --name=kube-apiserver -q))
```
