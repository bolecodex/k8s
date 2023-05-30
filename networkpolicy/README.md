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
kubectl exec -it nwp-busybox -n nwp-namespace -- wget --spider --timeout=1 nwp-nginx.default.svc.cluster.local is allowed
```
