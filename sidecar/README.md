# Demo: Running a Sidecar Container
```
kubectl create -f sidecar.yaml
kubectl exec -it sidecar-pod -c sidecar -- /bin/bash
yum install -y curl
curl http://localhost/date.txt
```