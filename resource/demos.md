Understanding Quota and Resources
• Quota are set on namespaces to limit the availability of resources
• Resource requests and limits are set on applications to specify required resources and resource limits
• If an application is started in a namespace that has quota, the application must have resource requests specified

# Demo: Managing Quota
```
kubectl create quota -h | less
kubectl create quota qtest --hard pods=3,cpu=100m,memory=500Mi -n limited
kubectl describe quota -n limited
kubectl create deploy nginx --image=nginx:latest --replicas=3 -n limited
kubectl get all -n limited # no pods
kubectl describe rs/nginx-xxx -n limited # it fails because no quota have been set on the deployment
kubectl set resources deploy nginx --requests cpu=100m,memory=5Mi --limits cpu=200m,memory=20Mi -n limited
kubectl get pods -n limited
```
