# Demo: Using a Secret to Provide Passwords
```
kubectl create secret generic dbpw --from-literal=ROOT_PASSWORD=password
kubectl describe secret dbpw
kubectl get secret dbpw -o yaml
kubectl create deploy mynewdb --image=mariadb
kubectl set env deploy mynewdb --from=secret/dbpw --prefix=MYSQL_
kubectl get deploy mynewdb -o yaml | less
```
