# Demo: Generating a YAML File with Variables
```
kubectl create deploy mydb --image=mariadb
kubectl describe pods mydb-xxx-yyy
kubectl logs mydb-xxx-yyy
kubectl set env deploy mydb MYSQL_ROOT_PASSWORD=password
kubectl get deploy mydb -o yaml > mydb.yaml # don't forget to clean it up!
```