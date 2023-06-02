# Demo: Using curl to Access API Resources
```
# On the host that runs kubectl: 
kubectl proxy --port=8001 &
kubectl create deploy curlnginx --image=nginx --replicas=3
curl http://localhost:8001/version
curl http://localhost:8001/api/v1/namespaces/default/pods # shows the Pods
curl http://localhost:8001/api/v1/namespaces/default/pods/curlnginx-xxx-yyy/ # shows direct API access to a Pod
curl -XDELETE
http://localhost:8001/api/v1/namespaces/default/pods/curlnginx-xxx-yyy # will delete the httpd Pod
```

# Exercise 5.1 - Configuring TLS Access

1.kubectl review (check 3 certificates, API server address)

```
less $HOME/.kube/config
```

Arrow down key, space bar input to check the file

When finished, press q to exit less.

##

2. Save the certificate information as a variable and confirm the variable save

```
export client=$(grep client-cert $HOME/.kube/config |cut -d" " -f 6)
export key=$(grep client-key-data $HOME/.kube/config |cut -d " " -f 6)
export auth=$(grep certificate-authority-data $HOME/.kube/config |cut -d " " -f 6)
echo $client
echo $key
echo $auth
```

##

3. Encode the key for use with curl

```
echo $client | base64 -d -> ./client.pem
echo $key | base64 -d -> ./client-key.pem
echo $auth | base64 -d -> ./ca.pem
```

##

4. Check the URL of the API server

```
kubectl config view |grep server
```

##

5. https access using curl (output pods information to API server)

```
curl --cert ./client.pem \
--key ./client-key.pem \
--cacert ./ca.pem \
https://k8scp:6443/api/v1/pods
```

##

6. Create curlpod.json file on CP node

```
cat <<EOF > curlpod.json
{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata":{
        "name": "curlpod",
        "namespace": "default",
        "labels": {
            "name": "examplepod"
        }
    },
    "spec": {
        "containers": [{
            "name": "nginx",
            "image": "nginx",
            "ports": [{"containerPort": 80}]
        }]
    }
}
EOF
```

##

7. Call the XPOST API using the previous curl command

```
curl \
--cert ./client.pem --key ./client-key.pem --cacert ./ca.pem \
https://k8scp:6443/api/v1/namespaces/default/pods\
-XPOST -H'Content-Type: application/json' -d@curlpod.json
```

##

8.pod check

```
kubectl get pods
```


#Exercise 5.2


1. Strace installation (debugging tool used to trace system calls and signals to check if there are any parts that cause performance degradation or errors)
```
sudo apt-get install -y strace
```

##

2.ep check command
```
kubectl get endpoints
strace kubectl get endpoints
```

##

3. Move directory
```
cd /home/ubuntu/.kube/cache/discovery/k8scp_6443
ls
```

##

4. Confirm with the find command
```
find.
```

##

5. Check the resources available in API version 1
```
python3 -m json.tool v1/serverresources.json
```

##

6. endpoints abbreviation search
```
python3 -m json.tool v1/serverresources.json | less
```
```
/endpoints
```
When the search is complete, press <q> to quit less

##

7. Endpoint lookup using abbreviations
```
kubectl get ep
```

##

8.kind count check
```
python3 -m json.tool v1/serverresources.json | grep kind
```

##

9. Check other apiversions
```
python3 -m json.tool apps/v1/serverresources.json | grep kind
```

##

10. Delete the pod
```
kubectl delete po curlpod
```
