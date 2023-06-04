Demo Step 1: Running the Old Version
```
kubectl create deploy old-nginx --image=nginx:1.14 --replicas=3 --dry-run=client -o yaml > ~/oldnginx.yaml
vim oldnginx.yaml
# set labels: type: canary in deploy metadata as well as Pod metadata
kubectl create -f oldnginx.yaml
kubectl expose deploy old-nginx --name=oldnginx --port=80 --selector type=canary
kubectl get svc; kubectl get endpoints
minikube ssh; curl <svc-ip-address>
# a few times, you'll see all the same
```

Demo Step 2: Creating a ConfigMap
```
kubectl cp <old-nginx-pod>:usr/share/nginx/html/index.html index.html
vim index.html
Add a line that uniquely identifies this as the canary Pod
kubectl create configmap canary --from-file=index.html
kubectl describe cm canary
```

Demo Step 3: Preparing the New Version
```
cp oldnginx.yaml canary.yaml
vim canary.yaml
# 	image: nginx:latest
# 	replicas: 1
# 	:%s/old/new/g
# 	Mount the configMap as a volume (see Git repo canary.yaml)
kubectl create -f canary.yaml
kubectl get svc; kubectl get endpoints
minikube ssh
curl <service-ip>
# notice different results: this is canary in action
```

Demo Step 4: Activating the New Version
```
kubectl get deploy # verify the names of the old and the new deployment
kubectl scale deploy new-nginx --replicas=2
kubectl scale deploy old-nginx --replicas=2
kubectl scale deploy new-nginx --replicas=3
kubectl scale deploy old-nginx --replicas=1
# scale the canary deployment up to the desired number of replicas
kubectl delete deploy old-nginx # delete the old deployment
```