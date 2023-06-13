# Demo: Using Jobs
```
kubectl create job onejob --image=busybox -- date
kubectl get jobs
kubectl get pods
kubectl get jobs onejob -o yaml | grep restartPolicy
kubectl delete job onejob
kubectl create job mynewjob --image=busybox --dry-run=client -o yaml -- sleep 5 > mynewjob.yaml
#Edit mynewjob.yaml and include the following in job.spec
#   completions: 3
#   ttlSecondsAfterFinished: 60
kubectl create -f mynewjob.yaml
```
# Exercise

>job

1. job creation
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: sleepy
spec:
  template:
    spec:
      containers:
      - name: resting
        image: busybox
        command: ["/bin/sleep"]
        args: ["3"]
      restartPolicy: Never
EOF
```

##

2. job confirmation
```
kubectl get job
kubectl describe job sleepy
```

##

3. Check in yaml format
```
kubectl get job sleepy -o yaml
```

##

4. Delete the job after a certain amount of time has elapsed and the status of the job is completed
```
kubectl delete job sleepy
```

##

5. Recreate the job with the command below (add the completion option)
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: sleepy
spec:
  completions: 5
  template:
    spec:
      containers:
      - name: resting
        image: busybox
        command: ["/bin/sleep"]
        args: ["3"]
      restartPolicy: Never
EOF
```

##

6. Check job execution
```
kubectl get job
```

##

7. Delete when the job is complete
```
kubectl delete job sleepy
```

##

8. Create a job again with the command below (Parallelism option added)
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: sleepy
spec:
  completions: 5
  parallelism: 2
  template:
    spec:
      containers:
      - name: resting
        image: busybox
        command: ["/bin/sleep"]
        args: ["3"]
      restartPolicy: Never
EOF
```

##

9. Check job execution
```
kubectl get job
```

##

10. Delete after confirmation of execution
```
kubectl delete job sleepy
```

##

11. Create a job again with the command below (add activeDeadlineSeconds option)
```
cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: sleepy
spec:
  completions: 5
  parallelism: 2
  activeDeadlineSeconds: 15
  template:
    spec:
      containers:
      - name: resting
        image: busybox
        command: ["/bin/sleep"]
        args: ["3"]
      restartPolicy: Never
EOF
```

##

12. Check with the following command every 3 seconds for 15 seconds
```
kubectl get job
```
After 15 seconds, approximately 3 out of 5 completed, the rest exited without completion

##

13. Check Stauts field in yaml form
```
kubectl get job sleepy -o yaml
```

##

14. Job deletion
```
kubectl delete job sleepy
```
