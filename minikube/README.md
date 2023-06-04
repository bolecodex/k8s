# Install minikube
```
git clone https://github.com/bolecodex/k8s.git
cd k8s/minikube
sh minikube-docker-setup.sh
```
# Testing Minikube
```
minikube ssh # logs in to the Minikube host
docker ps # shows all Docker processes on the MK host
ps aux | grep localkube # shows the localkube process on MK host
kubectl get all # shows current resources that have been created
```
