# Exercise 6.1


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
curl https://k8scp:6443/apis --header "Authorization: Bearer $token" -k
```

##

5.v1 Check Information
```
curl https://k8scp:6443/api/v1 --header "Authorization: Bearer $token" -k
```

##

6. Check namespace information
```
curl \
https://k8scp:6443/api/v1/namespaces --header "Authorization: Bearer $token" -k
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

> When creating a Pod, a token is generated and applied, so it is different from the previous token value


Close the connection after confirming

```
exit
```

##

8. Pod Delete
```
kubectl delete under busybox
```


# Exercise 6.2


1. Check proxy command help
```
kubectl proxy -h
```

##

2.Set API prefix and start proxy
```
kubectl proxy --api-prefix=/ &
```

##

3. access the api using curl
```
curl http://127.0.0.1:8001/api/
```

##

Access by namespace using 4.curl
```
curl http://127.0.0.1:8001/api/v1/namespaces
```

##

5.Exit proxy
```
ps
```
Kill the identified proxy process kubectl
```
kill -9 <ps num>
```

