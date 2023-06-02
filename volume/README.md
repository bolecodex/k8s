# Demo: Using Pod Local Storage
```
kubectl explain pod.spec.volumes
cat morevolumes.yaml
kubectl create -f morevolumes.yaml
kubectl get pods morevol
kubectl describe pods morevol | less ## verify there are two containers in the Pod
kubectl exec -ti morevol -c centos1 -- touch /centos1/test
kubectl exec -ti morevol -c centos2 -- ls -l /centos2
```
