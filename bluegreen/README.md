# Demo: Using Blue/Green Deployments
```
kubectl create deploy blue-nginx --image=nginx:1.14 --replicas=3
kubectl expose deploy blue-nginx --port=80 --name=bgnginx
kubectl get deploy blue-nginx -o yaml > green-nginx.yaml
# Clean up dynamic generated stuff
# Change Image version
# Change "blue" to "green" throughout
kubectl create -f green-nginx.yaml
kubectl get pods
kubectl delete svc bgnginx; kubectl expose deploy green-nginx --port=80 --name=bgnginx
kubectl delete deploy blue-nginx
```