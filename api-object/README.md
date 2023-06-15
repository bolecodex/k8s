# Demo 1: Bearer Token
```
1. Create a Pod, using the standard ServiceAccount: kubectl apply -f
mypod.yaml
2. Use kubectl get pods mypod -o yaml to check current SA configuration
3. Access the Pod using kubectl exec -it mypod -- sh, try to list Pods using curl on the API:
  1. apk add --update curl
  2. curl https://kubernetes/api/v1 --insecure will be forbidden
4. Use the Default ServiceAccount token and try again:
  1. TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
  2. curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/ --insecure
5. Try the same, but this time to list Pods - it will fail:
  curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
```

# Demo 2: RBAC API 
```
1. Create a ServiceAccount: 
kubectl apply -f mysa.yaml
2. Define a role that allows to list all Pods in the default NameSpace: 
kubectl apply -f list-pods.yaml
3. Define a RoleBinding that binds the mysa to the Role just created: 
kubectl apply -f list-pods-mysa-binding.yaml
4. Create a Pod that uses the mysa SA to access this Role: 
kubectl apply -f mysapod.yaml
5. Access the Pod using k exec -it mysapod -- sh, use the mysa ServiceAccount token and try again:
  1. apk add --update curl
  2. TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
  3. curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/ --insecure
6. Try the same, but this time to list Pods:
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
```

# Exercise 1


1. Check cluster configuration settings
```
kubectl config view
```

##

2. Token Generation
```
kubectl create token default
```

##


3. Save the token value as a variable
```
export token=<token value output in step 2>
```

##

4. Test if you can check the basic API information of the cluster
```
curl https://<control node name>:6443/apis --header "Authorization: Bearer $token" -k
```

##

5. v1 Check Information
```
curl https://<control node name>:6443/api/v1 --header "Authorization: Bearer $token" -k
```

##

6. Check namespace information
```
curl \
https://<control node name>:6443/api/v1/namespaces --header "Authorization: Bearer $token" -k
```

##

7. After creating the Pod, check the token in the Pod
```
kubectl run -i -t busybox --image=busybox --restart=Never
```
Running commands inside a Pod
```
ls /var/run/secrets/kubernetes.io/serviceaccount/
```
```
cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

> When creating a Pod, a token is generated and applied, so it is different from the previous token value. The contents of the token is of the JSON Web Token (JWT) format. https://jwt.io/


Close the connection after confirming

```
exit
```

##

8. Pod Delete
```
kubectl delete pod busybox
```


# Exercise 2


1. Check proxy command help
```
kubectl proxy -h
```

##

2. Set API prefix and start proxy
```
kubectl proxy --api-prefix=/ &
```

##

3. access the api using curl
```
curl http://127.0.0.1:8001/api/
```

##

4. Access by namespace using curl
```
curl http://127.0.0.1:8001/api/v1/namespaces
```

##

5. Exit proxy
```
ps aux | grep kubectl
```
Kill the identified proxy process kubectl
```
kill -9 <ps num>
```

