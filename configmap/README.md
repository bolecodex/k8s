# Demo 1: Providing Variables with ConfigMaps
```
vim varsfile
MYSQL_ROOT_PASSWORD=password
MYSQL_USER=anna
kubectl create cm mydbvars --from-env-file=varsfile
kubectl create deploy mydb --image=mariadb --replicas=3
kubectl get all --selector app=mydb
kubectl set env deploy mydb --from=configmap/mydbvars
kubectl get all --selector app=mydb
kubectl get deploy mydb -o yaml
```

# Demo 2: Using a ConfigMap with a Configuration File
```
echo "hello world" > index.html
kubectl create cm myindex --from-file=index.html
kubectl describe cm myindex
kubectl create deploy myweb --image=nginx --dry-run=client -o yaml > cm.yaml
vim cm.yaml
```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: myweb
  name: myweb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myweb
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: myweb
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: cmvol
      volumes:
      - name: cmvol
        configMap:
          name: myindex
status: {}
```
```
kubectl apply -f cm.yaml
kubectl expose deploy myweb --port=80
kubectl get svc myweb
curl <cluster-ip>
```

# Exercise


1. Create a directory and create a file to use for practice
```
mkdir primary
echo c > primary/cyan
echo m > primary/magenta
echo y > primary/yellow
echo k > primary/black
echo "known as key" >> primary/black
echo blue > favorite
```

##

2. Create configmap
```
kubectl create configmap colors \
--from-literal=text=black \
--from-file=./favorite \
--from-file=./primary/
```

##

3. Check the configmap
```
kubectl get configmap colors
```

##

4. Output in yaml format
```
kubectl get configmap colors -o yaml
```

##

5. Create a Pod using Configmap
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: shell-demo
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: ilike
      valueFrom:
        configMapKeyRef:
          name: colors
          key: favorite
EOF
```

##

6. Check the configmap environment variable set in Pod
```
kubectl exec shell-demo -- /bin/bash -c 'echo $ilike'
```

##

7. Delete the pod
```
kubectl delete pod shell-demo
```

##

8. Redeploy with the command below
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: shell-demo
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: colors
EOF
```

##

9. Check all environment variables of the Pod created above
```
kubectl exec shell-demo -- /bin/bash -c 'env'
```

##

10. Pod Delete
```
kubectl delete pod shell-demo
```

##

11. Create a Configmap with the command below
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: fast-car
  namespace: default
data:
  car.make: Ford
  car.model: Mustang
  car.trim: Shelby
EOF
```

##

12. Check in yaml format
```
kubectl get cm fast-car -o yaml
```

##

13. Create a Pod that uses the configmap created above
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: shell-demo
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
      - name: car-vol
        mountPath: /etc/cars
  volumes:
    - name: car-vol
      configMap:
        name: fast-car
EOF
```

##

14. Check the directory mounted on the Pod created above
```
kubectl exec shell-demo -- /bin/bash -c 'df -ha |grep cars'
```

##

15. Check mounted file contents
```
kubectl exec shell-demo -- /bin/bash -c 'cat /etc/cars/car.trim; echo'
```

##

16. Pod, delete configmap
```
kubectl delete pod shell-demo
kubectl delete cm fast-car colors
```
