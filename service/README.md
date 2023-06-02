# Demo: Creating Services
```
kubectl create deployment nginxsvc --image=nginx
kubectl scale deployment nginxsvc --replicas=3
kubectl expose deployment nginxsvc --port=80
kubectl describe svc nginxsvc # look for endpoints
kubectl get svc nginxsvc -o=yaml
kubectl get svc
kubectl get endpoints
```
