# Task 1
```
Create a role with the name "viewers", which allows permissions to view pods in the namespaces "roles"

Create a Pod with the name "viewpod" in the namespaces "roles" which uses this role
```


# Exercise 15.2


1. Create NS
```
kubectl create ns development
kubectl create ns production
```

##

2. Check Current Context
```
kubectl config get-contexts
```

##

3.Generate a private key for DevDan users
```
openssl genrsa -out DevDan.key 2048
```

##

4.CSR(certificate Singing Request) 생성
```
touch $HOME/.rnd
openssl req -new -key DevDan.key -out DevDan.csr \
-subj "/CN=DevDan/O=development"
```

##

5.Self-signed Certificate 생성
```
sudo openssl x509 -req -in DevDan.csr \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial \
-out DevDan.crt -days 45
```

##

6. Apply the certificate created above to the currently configured kubeconfig
```
kubectl config set-credentials DevDan \
--client-certificate=/home/ubuntu/DevDan.crt \
--client-key=/home/ubuntu/DevDan.key
```

##

7. Comparing the kubeconfig file copied in the previous exercise with the current updated kubeconfig file
```
diff cluster-api-config .kube/config -y
```

##

8.Context Creation
```
kubectl config set-context DevDan-context \
--cluster=kubernetes \
--namespace=development \
--user=DevDan
```

##

9.Check the Pod of development NS using the Context created above
```
kubectl --context=DevDan-context get pods
```

##

10. Check the created context list
```
kubectl config get-contexts
```

##

11. Compare the kubeconfig file copied in the previous exercise and the currently updated kubeconfig file again
```
diff cluster-api-config .kube/config -y
```

##

12.Role Creation
```
cat <<EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: development
  name: developer
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["list", "get", "watch", "create", "update", "patch", "delete"]
EOF
```

##

13. Create Rolebinding
```
cat <<EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer-role-binding
  namespace: development
subjects:
- kind: User
  name: DevDan
  apiGroup: ""
roleRef:
  kind: Role
  name: developer
  apiGroup: ""
EOF
```

##

14.Check development NS Pod using DevDan-context Context
```
kubectl --context=DevDan-context get pods
```

##

15.Create Deployment in development namespace using DevDan-context Context
```
kubectl --context=DevDan-context create deployment nginx --image=nginx
```

##

16.Check development NS Pod using DevDan-context Context
```
kubectl --context=DevDan-context get pods
```

##

17.Delete Deployment in development namespace using DevDan-context Context
```
kubectl --context=DevDan-context delete deployment nginx
```

##

18.Role Creation
```
cat <<EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: production
  name: dev-prod
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch"]
EOF
```

##

19. Create Rolebinding
```
cat <<EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: production-role-binding
  namespace: production        
subjects:
- kind: Group
  name: development
  apiGroup: ""
roleRef:
  kind: Role
  name: dev-prod                
  apiGroup: ""
EOF
```

##

20.Context Creation
```
kubectl config set-context ProdDan-context \
--cluster=kubernetes \
--namespace=production \
--user=DevDan
```

##

21.Check the Pod of production NS using the Context created above
```
kubectl --context=ProdDan-context get pods
```

##

22.Create Deployment in production Namespace using ProdDan-context Context
```
kubectl --context=ProdDan-context create deployment nginx --image=nginx
```

##

23.Check the permissions of the dev-prod role
```
kubectl -n production describe role dev-prod
```

##

24.Check the list of actions that DevDan user can perform in deployment NS
```
kubectl auth can-i --as DevDan --list -n development
```

##

25.Check the list of actions that DevDan user can perform in production NS
```
kubectl auth can-i --as DevDan --list -n production
```

##

26. Check the list of actions that the user DevDan belongs to in production NS
```
kubectl auth can-i --as DevDan --as-group development --list -n production
```

##

27. Make sure DevDan user can create Deployment in production NS
```
kubectl auth can-i --as DevDan --as-group development create deploy -n production
```

##

28. Confirm that DevDan user can query the Deployment in production NS
```
kubectl auth can-i --as DevDan --as-group development get deploy -n production
```
