# Demo: Setting up Autoscaling
```
Resources are in the course Git repository at
https://github.com/sandervanvugt/ckad
cd ckad/autoscaling
sudo apt install docker.io
sudo docker build -t php-apache .
kubectl apply -f hpa.yaml # using the image from the Dockerfile as
provided by the image registry
kubectl get deploy; sleep 60
kubectl autoscale deployment php-apache --cpu-percent=1 --
min=1 --max=10
kubectl get hpa
```
```
From another terminal: kubectl run -it load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O - http://php-apache; done"
Back to the original terminal: sleep 60; kubectl get hpa
kubectl get hpa # may need 2 minutes
kubectl get deploy php-apache
kubectl delete pod load-generator
kubectl get hpa # may need 2 minutes
kubectl get deploy php-apache
```