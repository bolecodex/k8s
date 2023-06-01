# Demo
```
kubectl apply -f securitycontextdemo.yaml
kubectl exec -it security-context-demo -- sh
ps
cd /data; ls -l
cd demo; echo hello > testfile
ls -l
id
```