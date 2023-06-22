# Solution
```
kubectl create ns roles
kubectl create role viewers --verb=get,list,watch --resource=pods -n roles
kubectl create sa mysa -n roles
kubectl run viewpod -n roles --image=nginx --dry-run=client -o yaml > rbac.yaml
vim rbac.yaml
kubectl apply -f rbac.yaml
kubectl describe pod viewpod -n roles
kubectl create rolebinding viewers --role=viewers --serviceaccount=roles:mysa -n roles
```

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: viewpod
  name: viewpod
  namespace: roles
spec:
  serviceAccountName: mysa
  containers:
  - image: nginx
    name: viewpod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


```
