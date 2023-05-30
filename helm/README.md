# Exercise 10.1


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

4.Search the database keyword chart in Helm Hub
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

10. Curl communication with the above service
```
curl <above svc ip>
```

##

11. Check the helm chart record
```
helm list
```

##

12. Delete tester tool
```
helm uninstall tester
```

##

13. Recheck the helm chart record
```
helm list
```

##

14. Search the list of downloaded charts
```
find $HOME -name *echo*
```

##

15. Go to that directory and unzip
```
cd $HOME/.cache/helm/repository ; tar -xvf echo-server-*
```

##

16. Check the echo-server/values.yaml file
```
cat echo-server/values.yaml
```

##

17. Add bitnami apache repository, download chart
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

18. Check values.yaml
```
cat values.yaml
```

##

19. Chart Installation
```
helm install anotherweb .
```

##

20. Check the created resource
```
kubectl get all
```

##

21. Curl to the generated SVC IP
```
curl $(kubectl get svc anotherweb-apache -o=jsonpath='{.spec.clusterIP}')
```

##

22. Deploy by specifying the type of svc as clusterIP
```
helm upgrade anotherweb . --set service.type=ClusterIP
```

##

23. Check if svc type has changed
```
kubectl get svc anotherweb-apache
```

##

24. Check the list of installed charts
```
helm list
```

##

25. Delete anotherweb chart
```
helm uninstall anotherweb
```

##

26. Check Pod, svc again
```
kubectl get all
```