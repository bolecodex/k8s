# Demo 1: Installing the Helm Binary and create a demo application
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

helm create demo
helm install demo ./demo
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=demo,app.kubernetes.io/instance=demo" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
curl http://127.0.0.1:8080
# If you later want to kill the process currently on port 8080: sudo netstat -tulpen | grep 8080 shoud show which process that is, kill -9 <PID> allows you to kill it.
```
```
vim demo/{templates/{deployment,service,hpa},values,Chart}.yaml
# template package - text/template - Go Packages
# https://pkg.go.dev/text/template
vim demo/values.yaml
# repository: nginxdemos/hello
# tag: "latest"
vim demo/Chart.yaml
# version: 0.1.1
# appVersion: ""
helm upgrade demo ./demo
helm list
helm history demo
helm rollback demo
helm history demo
helm rollback demo
```
# Demo 2: Managing Helm Repositories
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm search repo bitnami
helm repo update
```
# Demo 3: Installing Helm Charts
```
helm install bitnami/mysql --generate-name
kubectl get all
helm show chart bitnami/mysql
helm show all bitnami/mysql
helm list
helm status mysql-xxxx
```
# Demo 4: Customizing Before Install
```
helm show values bitnami/nginx
helm pull bitnami/nginx
tar xvf nginx-xxxx
vim nginx/values.yaml
helm template --debug nginx
helm install -f nginx/values.yaml my-nginx nginx/\
helm delete my-nginx
```
# Exercise


1. Download helm with wget
```
wget https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz
```

##

2. Decompression
```
tar -xvf helm-v3.9.2-linux-amd64.tar.gz
```

##

3. Copy to use as a command
```
sudo cp linux-amd64/helm /usr/local/bin/helm
```

##

4. Search the database keyword chart in Helm Hub
```
helm search hub database
```

##

5. Add Helm Repository
```
helm repo add ealenn https://ealenn.github.io/charts
```

##

6. Repository Update
```
helm repo update
```

##

7. Install the tester tool
```
helm upgrade -i tester ealenn/echo-server  --debug
```

##

8. Check if the deployed pod is running
```
kubectl get pod
```

##

9. Check the deployed svc
```
kubectl get svc
```

##

10. Check the helm chart record
```
helm list
```

##

11 Delete tester tool
```
helm uninstall tester
```

##

12. Recheck the helm chart record
```
helm list
```

##

13. Search the list of downloaded charts
```
find $HOME -name *echo*
```

##

14. Go to that directory and unzip
```
cd $HOME/.cache/helm/repository ; tar -xvf echo-server-*
```

##

15. Check the echo-server/values.yaml file
```
cat echo-server/values.yaml
```

##

16. Add bitnami apache repository, download chart
```
cd
helm repo add bitnami https://charts.bitnami.com/bitnami
```

```
helm fetch bitnami/apache --untar
```

```
cd apache/
```

##

17. Check values.yaml
```
cat values.yaml
```

##

18. Chart Installation
```
helm install anotherweb .
```

##

19. Check the created resource
```
kubectl get all
```

##

20. Deploy by specifying the type of svc as clusterIP
```
helm upgrade anotherweb . --set service.type=ClusterIP
```

##

21. Check if svc type has changed
```
kubectl get svc anotherweb-apache
```

##

22. Check the list of installed charts
```
helm list
```

##

23. Delete anotherweb chart
```
helm uninstall anotherweb
```

##

24. Check Pod, svc again
```
kubectl get all
```
