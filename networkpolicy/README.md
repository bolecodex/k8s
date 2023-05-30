# Demo1: Exploring NetworkPolicy
```
kubectl apply -f nwpolicy-complete-example.yaml
kubectl expose pod nginx --port=80
kubectl exec -it busybox -- wget --spider --timeout=1 nginx will fail
kubectl label pod busybox access=true
kubectl exec -it busybox -- wget --spider --timeout=1 nginx will work
```
# Demo2: Using NetworkPolicy between Namespaces
```
kubectl create ns nwp-namespace
kubectl create -f nwp-lab9-1.yaml
kubectl expose pod nwp-nginx --port=80
kubectl exec -it nwp-busybox -n nwp-namespace -- wget --spider --timeout=1 nwp-nginx # gives a bad address error
kubectl exec -it nwp-busybox -n nwp-namespace -- nslookup nwp-nginx
# explains that it's looking in the wrong ns
kubectl exec -it nwp-busybox -n nwp-namespace -- nslookup nwp-nginx.default.svc.cluster.local
kubectl exec -it nwp-busybox -n nwp-namespace -- wget --spider --timeout=1 nwp-nginx.default.svc.cluster.local
# now it is allowed
```
# Demo3: Using NetworkPolicy between Namespaces
```
kubectl create -f nwp-lab9-2.yaml
kubectl exec -it nwp-busybox -n nwp-namespace -- wget --spider --timeout=1 nwp-nginx.default.svc.cluster.local # it is not allowed
kubectl create deployment busybox --image=busybox -- sleep 3600
kubectl exec -it busybox[Tab] -- wget --spider --timeout=1 nwp-nginx
```

# Task 1
Create a NetworkPolicy that applies to the namespace resticted and
provides access only to pods that are running nginx and which are
running in that namespace. Only pods coming from the default
namespace provided with the label access=yes should be allowed
access
