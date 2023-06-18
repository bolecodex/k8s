# Install Minikube
```
# At least 2VCPU, 20GB Volume
git clone https://github.com/bolecodex/k8s.git
cd k8s/minikube
sh minikube-docker-setup.sh
```
# Testing Minikube
```
minikube start --vm-driver=docker --cni=calico
minikube ssh # logs in to the Minikube host
docker ps # shows all Docker processes on the MK host
exit
alias kubectl="minikube kubectl --"
kubectl get all # shows current resources that have been created
```
# Demo: Creating Services
```
kubectl create deployment nginxsvc --image=nginx
kubectl scale deployment nginxsvc --replicas=3
kubectl expose deployment nginxsvc --port=80
kubectl describe svc nginxsvc # look for endpoints
kubectl get svc nginxsvc -o=yaml
kubectl get svc
kubectl get endpoints
```

# Demo: Accessing Applications Using Services
```
minikube ssh
curl http://svc-ip-address
exit
kubectl edit svc nginxsvc
#   …
#   protocol: TCP
#   nodePort: 32000
# type: NodePort
kubectl get svc
(from host): curl http://$(minikube ip):32000
```

# Demo: Running the Minikube Ingress Addon
```
minikube addons list
minikube addons enable ingress
kubectl get ns
kubectl get pods -n ingress-nginx
```

# Demo: Creating Ingress
```
kubectl get deployment
kubectl get svc nginxsvc
curl http://$(minikube ip):32000
kubectl create ingress nginxsvc-ingress --rule="/=nginxsvc:80" --rule="/hello=newdep:8080"
minikube ip
# The hosts file  is a text file used by operating systems to map IP addresses to host names/domain names. 
sudo vim /etc/hosts
# $(minikube ip) nginxsvc.info
# notice that you need to replace $(minikube ip) with the returned IP address
kubectl get ingress # wait until it shows an IP address
curl nginxsvc.info
kubectl create deployment newdep --image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment newdep --port=8080
curl nginxsvc.info/hello
```
