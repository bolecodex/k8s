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

# Exercise 1


1. Distribute load generation Deployment
```
kubectl create deployment hog --image vish/stress
kubectl get deployment
```

##

2. Check details and check in yaml format
```
kubectl describe deployment hog
kubectl get deployment hog -o yaml
```

##

3. Save as yaml file
```
kubectl get deployment hog -o yaml > hog.yaml
```

##

4. Open the file to modify
```
we hog.yaml
```
Modify spec.template.spec.containers[0].resources as below
```
        resources:
          limits:
            memory: "4Gi"
          requests:
            memory: "2500Mi"
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
```

##

5. Redistribution as an edited file
```
kubectl replace -f hog.yaml
```

##

6. Check again in yaml form
```
kubectl get deployment hog -o yaml
```

##

7. Check the log of pod
```
kubectl get pods
```
```
kubectl logs <pod name from above>
```

8. Open two more terminals, access CP and worker, and run the top command
```
top
```
Check CPU usage

##

9. Change the CPU memory stress factor by modifying the hog.yaml file
```
we hog.yaml
```
Modify spec.template.spec.containers[0].args as below
```
resources:
  limits:
    cpu: "1"
    memory: "4Gi"
  requests:
    cpu: "0.5"
    memory: "500Mi"
args:
- -cpus
- "2"
- -mem-total
- "950Mi"
- -mem-alloc-size
- "100Mi"
- -mem-alloc-sleep
- "1s"
```  

##

10. Redeployment after deleting Deployment
```
kubectl delete deployment hog
```
```
kubectl create -f hog.yaml
```

Check the usage on the node where the top command was executed again


# Exercise 2


1. Create and confirm a new Namespace
```
kubectl create namespace low-usage-limit
kubectl get ns
```

##

2. Create a LimitRange that limits the use of cpu and memory
```
cat <<EOF | kubectl -n low-usage-limit create -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: low-resource-range
spec:
  limits:
  -default:
      CPU: 1
      Memory: 500 Mi
    defaultRequest:
      CPU: 0.5
      Memory: 100 Mi
    type: Container
EOF
```

##

3. Check LimitRange
```
kubectl get limitrange
kubectl get LimitRange --all-namespaces
```

##

4. Deploy Deployment in low-usage-limit namespace
```
kubectl -n low-usage-limit \
create deployment limited-hog --image vish/stress
```

##

5. Deployment confirmation
```
kubectl get deployments --all-namespaces
```

##

6. Check the deployed Pod
```
kubectl -n low-usage-limit get pods
```


##

7. Output the pod checked above in yaml
```
kubectl -n low-usage-limit \
get pod <pod name> -o yaml
```

Check if the CPU and Memory are set to the default settings set in Limitrange

##

8. Copy hog.yaml to hog2.yaml and edit.
```
cp hog.yaml hog2.yaml
```
```
vi hog2.yaml
```

Modify metadata.namespace as below
```
  labels:
    app: hog
  name: hog
  namespace: low-usage-limit
  selfLink: /apis/apps/v1/namespaces/default/deployments/hog
spec:
```

##

9. Distribution as a modified file
```
kubectl create -f hog2.yaml
```

##

10. Query Deployments in All Namespaces
```
kubectl get deployment --all-namespaces
```
2 Deployments named hog (different namespaces)

##

11. Check the terminal where the top command was executed

##

12. Delete hog Deployment
```
kubectl -n low-usage-limit delete deployment hog
kubectl delete deployment hog
```

##
