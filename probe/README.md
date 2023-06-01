# Demo 1: Using ReadinessProbe
```
kubectl create –f busybox-ready.yaml
kubectl get pods 
# note the READY state, which is set to 0/1, which means that the Pod has successfully started, but is not considered ready.
kubectl edit pods busybox-ready and change /tmp/nothing to /etc/hosts.
# Notice this is not allowed.
kubectl exec –it busybox-ready -- /bin/sh
touch /tmp/nothing; exit
kubectl get pods
# at this point we have a Pod that is started
```
# Demo 2: Using LivenessProbe
```
kubectl create –f nginx-probes.yaml
kubectl get pods
```
