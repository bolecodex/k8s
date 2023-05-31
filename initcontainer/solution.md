apiVersion: v1
kind: Pod
metadata:
  name: task4pod
  labels:
    run: task4pod
spec:
  initContainers:
  - name: init
    image: alpine
    command: ['sh', '-c', "touch /data/runfile.txt"]
    volumeMounts:
    - name: workdir
      mountPath: "/data"
  containers:
  - name: tasks
    image: busybox
    command: ['sh', '-c', "sleep 10000"]
  volumes:
  - name: workdir
    emptyDir: {}