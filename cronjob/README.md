# Demo: Managing Cron Jobs
```
kubectl create cronjob -h | less
kubectl create cronjob runme --image=busybox --schedule="*/1 * * * *" --
echo greetings from your cluster
kubectl get cronjobs,jobs,pods
kubectl logs runme-xxx-yyy
kubectl delete cronjob runme
```