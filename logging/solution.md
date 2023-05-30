# Task 1
Create a pod with the name task6pod that runs Busybox with a command that writes "hello from the cluster" to a file with the name /messages/index.html

Configure this pod with an emptydir type shared volume that is mounted on the directory /messages

Add a sidecar container to this pod, that runs nginx and mounts the shared volume on /usr/lib/nginx/html/

Expose the Pod in such a way that users can access the file presented by the Nginx webserver by addressing a port that is externally exposed on your Kubernetes nodes
# Solution
```
apiVersion: v1
kind: Pod
metadata:
  name: task6pod
  label:
    run: nginx
spec:
  containers:
  - name: busybox
    image: busybox:1.28
    args:
    - /bin/sh
    - -c
    - >
      echo "hello from the cluster" > /messages/index.html;
      sleep 3600;
    volumeMounts:
    - name: messages
      mountPath: /messages
  - name: nginx
    image: nginx
    volumeMounts:
    - name: messages
      mountPath: /usr/share/nginx/html/
  volumes:
  - name: messages
    emptyDir: {}
```
```
kubectl apply -f task6pod.yaml
kubectl expose task6pod --port=80 --type=NodePort
```
