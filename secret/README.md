# Demo 1: Using a Secret to Provide Passwords
```
kubectl create secret generic dbpw --from-literal=ROOT_PASSWORD=password
kubectl describe secret dbpw
kubectl get secret dbpw -o yaml
kubectl create deploy mynewdb --image=mariadb
kubectl set env deploy mynewdb --from=secret/dbpw --prefix=MYSQL_
kubectl get deploy mynewdb -o yaml | less
```
# Demo 2： Using a Secret for Docker Credentials
```
kubectl create secret docker-registry my-docker-credentials --docker-username=unclebob --docker-password=mypw --docker-email=uncel@bob.com --docker-server=myregistry:5000
kubectl get secret my-docker-credentials -o yaml
kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
```
```
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred
```
