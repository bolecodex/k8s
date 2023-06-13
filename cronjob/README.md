# Demo: Managing Cron Jobs
```
kubectl create cronjob -h | less
kubectl create cronjob runme --image=busybox --schedule="*/1 * * * *" -- echo greetings from your cluster
kubectl get cronjobs,jobs,pods
kubectl logs runme-xxx-yyy
kubectl delete cronjob runme
```
# Exercise

>cronjob

1. Create a cronjob
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sleepy
spec:
  schedule: "*/2 * * * *" # https://crontab.guru/
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: resting
            image: busybox
            command: ["/bin/sleep"]
            args: ["5"]
          restartPolicy: Never
EOF
```
##

2. cronjob verification
```
kubectl get cronjob
```

##

3. job confirmation
```
kubectl get job
```

##

4. Check again after about 2 minutes
```
kubectl get cronjob
kubectl get job
```

5. Delete cronjob
```
kubectl delete cronjob sleepy
```

6. Deploy by adding an option with the command below (activeDeadlineSeconds)
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sleepy
spec:
  schedule: "*/2 * * * *"
  jobTemplate:
    spec:
      activeDeadlineSeconds: 10  
      template:
        spec:
          containers:
          - name: resting
            image: busybox
            command: ["/bin/sleep"]
            args: ["30"]
          restartPolicy: Never
EOF
```

##

7. Check cronjob and job
```
kubectl get cronjob
kubectl get job
```

##

8. Confirm that the completion count does not start after 10 seconds
```
kubectl get cronjob
kubectl get job
```

##

9. Delete cronjob
```
kubectl delete cronjob sleepy
```
