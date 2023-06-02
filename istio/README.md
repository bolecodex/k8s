# Demo 1: Download and Install Istio
```
curl -L https://istio.io/downloadIstio | sh -
cd istio-[Tab]
sudo cp bin/istioctl /usr/bin/
istioctl install --set profile=demo -y
kubectl get all -n istio-system
kubectl label namespace default istio-injection=enabled
kubectl get crds
```