# Task 1
```
Create a Pod with the name task2pod that runs the latest version of the alpine image. 
This pod should be configured to run the sleep 3600 command repeatedly and it should be created in the mynamespace namespace
```
# Solution 1
```
kubectl create ns mynamespace
kubectl run -n mynamespace task2pod --image=alpine -- sleep 3600
kubetcl get pods -n mynamespace
```


# Task 2
```
• Schedule a Pod with the name task3pod that runs containers based
on the 3 following images
  • redis
  • nginx
  • busybox
```
# Solution 2
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: task3pod
  name: task3pod
spec:
  containers:
  - image: nginx
    name: nginx
  - image: busybox
    name: busybox
    args:
    - sleep
    - "3600"
  - name: redis
    image: redis
EOF
```
