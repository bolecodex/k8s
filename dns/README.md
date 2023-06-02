# Demo: Using Service DNS Information
```
kubectl run testpod --image=busybox -- sleep 3600
kubectl create deployment nginxsvc --image=nginx
kubectl expose deployment nginxsvc --port=80
kubectl get svc # should show the name of the busybox service
kubectl get svc,pods -n kube-system
kubectl exec -it testpod -- cat /etc/resolv.conf
kubectl exec -it testpod -- nslookup nginxsvc.default.svc.cluster.local
```
