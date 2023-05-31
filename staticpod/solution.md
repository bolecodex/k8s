# Solution
```
# worker1 node
sudo mkdir /etc/kubernetes/static
sudo vi /etc/kubernetes/static/pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: auto-web
  name: auto-web
spec:
  containers:
  - image: nginx
    name: auto-web
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


sudo vim /var/lib/kubelet/config.yaml
...
staticPodPath: /etc/kubernetes/static
...


sudo systemctl restart kubelet

# Control node
kubectl get pods
```