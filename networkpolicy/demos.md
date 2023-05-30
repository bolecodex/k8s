```
kubectl apply -f nwpolicy-complete-example.yaml
kubectl expose pod nginx --port=80
kubectl exec -it busybox -- wget --spider --timeout=1 nginx will fail
kubectl label pod busybox access=true
kubectl exec -it busybox -- wget --spider --timeout=1 nginx will work
```
