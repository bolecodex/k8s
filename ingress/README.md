# Demo: Installing Nginx Ingress Controller
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl get pods -n ingress-nginx
kubectl create deploy nginxsvc --image=nginx --port=80
kubectl expose deploy nginxsvc
kubectl describe svc nginxsvc 

kubectl create ingress nginxsvc --class=nginx --rule=nginxsvc.info/*=nginxsvc:80
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
# press "ctrl" + "z"
bg
sudo -i
echo "127.0.0.1 nginxsvc.info" >> /etc/hosts
exit
curl nginxsvc.info:8080
```

# Exercise 11.1


1.Linkerd installation
```
curl -sL run.linkerd.io/install | LINKERD2_VERSION=stable-2.10.1 sh
export PATH=$PATH:/home/ubuntu/.linkerd2/bin
echo "export PATH=$PATH:/home/ubuntu/.linkerd2/bin" >> $HOME/.bashrc
linkerd check --pre
linkerd install | kubectl apply -f -
linkerd check
linkerd viz install --set dashboard.enforcedHostRegexp=" " | kubectl apply -f -
linkerd viz check
linkerd viz dashboard &
```

##

2. Modify options to allow external access
```
kubectl -n linkerd-viz edit deploy web
```
In spec.containers.args - remove -enforced-host= entry

```
spec:
  containers:
  - args:
    - -linkerd-controller-api-addr=linkerd-controller-api.linkerd.svc.cluster.local:8085
    --linkerd-metrics-api-addr=metrics-api.linkerd-viz.svc.cluster.local:8085
    --cluster-domain=cluster.local
    --grafana-addr=grafana.linkerd-viz.svc.cluster.local:3000
    --controller-namespace=linkerd
    --viz-namespace=linkerd-viz
    --log-level=info
    --enforced-host=    # this line
```

##

3. Change the deployed Service to Nodeport type
```
kubectl patch svc web --patch '{"spec":{"type":"NodePort"}}' -n linkerd-viz
```

##

4.Nodeport number confirmation
```
kubectl get svc web -n linkerd-viz
```

##

5. Connect to CP or Worker IP and node port checked above in web browser
```
<ANY NODE IP>:<Nodeport identified above>
```
You can check with below command
```
echo "$(curl -s ifconfig.io):$(kubectl -n linkerd-viz get svc web -o=jsonpath='{.spec.ports[?(@.port==8084)].nodePort}')"
```

##

6. Demo application (NS, Deployment, SVC) deployment
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: accounting
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-one
  labels:
    app: nginx-one
  namespace: accounting
spec:
  selector:
    matchLabels:
      app: nginx-one
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx-one
    spec:
      containers:
      - image: nginx:1.20.1
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-one
  namespace: accounting
spec:
  type: NodePort
  selector:
    app: nginx-one
  ports:
    - port: 80
EOF
```

##

7. Check deployment in Linkerd Dashboard

##

8. Add Linkerd Proxy to deployed Deployment
```
kubectl -n accounting get deploy nginx-one -o yaml | linkerd inject - | kubectl apply -f -
```

##

9. Check changes and also check on dashboard
```
kubectl get pod -n accounting
```

##

10. Check the ClusterIP of the created SVC
```
kubectl get svc nginx-one -n accounting
```

##

11. Generate traffic with created services
```
watch -n 0.1 curl $(kubectl get svc nginx-one -o=jsonpath='{.spec.clusterIP}' -n accounting)
```

##

12.Check the Deployment and Pod connected to the service on the dashboard

##

13.Adjust the number of replicas of Deployment
```
kubectl -n accounting scale deploy nginx-one --replicas=5
```

##

14.Generate traffic to the service
```
watch -n 0.1 curl $(kubectl get svc nginx-one -o=jsonpath='{.spec.clusterIP}' -n accounting)
```

##

15. Check Deployment or Pod metrics on the Dashboard

##

# Exercise 11.2 - Ingress Controller

1.Search ingress using helm

```
helm search hub ingress
```

##

2. Add nginx ingress chart repository

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

##

3.repo update

```
helm repo update
```

##

Download 4.yaml and change to Daemonset

```
helm fetch ingress-nginx/ingress-nginx --untar
```

```
cd ingress-nginx
vi values.yaml
```

about 190 lines

```
# -- Use a `DaemonSet` or `Deployment`
kind: DaemonSet # <-----Modify this part (note capitalization)
# -- Annotations to be added to the controller Deployment or DaemonSet
```

##

5. Install the controller using the helm chart

```
helm install myingress .
```

##

6. Check installation

```
kubectl get ingress --all-namespaces
kubectl get pod --all-namespaces | grep nginx
```

When the Pod is in the Running state, proceed to the next step

##

7. Create an ingress rule

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-test
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: www.external.com
    http:
      paths:
      - backend:
          service:
            name: web-one
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
status:
  loadBalancer: {}
EOF
```

##

8. Check ingress, Pod

```
kubectl get ingress
kubectl get pod -o wide | grep myingress
```

##

curl to the ip of the pod you checked in 9.8

```
curl <pod ip>
```

##

10.svc check

```
kubectl get svc | grep ingress
```

##

curl with the ip of the svc I checked on 11.10

```
curl <svc ip>
```

##

12. curl to the url of the ingress

```
curl -H "Host: www.external.com" svc ip from http://<10>
```

##

13. Add annotation to Linkerd's ingress pod

```
kubectl get ds myingress-ingress-nginx-controller -o yaml  | linkerd inject --ingress - | kubectl apply -f -
```

##

14.In the linkerd dashboard, select Top - Default namespace - select daemonset/myingress-ingress-nginx-controller - click the start button

![](../img/linkerd.png)

##

15. Deploy the demo application

```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-one
  labels:
    app: web-one
spec:
  selector:
    matchLabels:
      app: web-one
  replicas: 1
  template:
    metadata:
      labels:
        app: web-one
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-one
spec:
  type: ClusterIP
  selector:
    app: web-one
  ports:
    - port: 80
EOF
```

##

16. Connect to the created web-one pod

```
kubectl exec -it <the Pod name created above> -- /bin/bash
```

##

17. Web server simple configuration

```
apt-get update
apt-get install vim -y
vi /usr/share/nginx/html/index.html
```

Create index.html contents

```
<!DOCTYPE html> <html>
<head>
<title>Internal Welcome Page</title> #<-- edit this line   
<style>
<output_omitted>
```

disconnect pod

```
exit
```

##

Edit 18.ingress

```
kubectl edit ingress ingress-test
```

```
spec:
  rules:
  - host: internal.org #<-- change that line
    http:
```

##

19.curl test

```
curl -H "Host: internal.org" http://<ingress controller svc ip>/
```

or

```
curl -H "Host: internal.org" \
$(kubectl get svc myingress-ingress-nginx-controller -o=jsonpath='{.spec.clusterIP}')
```



> delete linkerd
```
linkerd uninstall | kubectl delete -f -
```
