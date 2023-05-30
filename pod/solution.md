kubectl create ns mynamespace
kubectl run -n mynamespace task2pod --image=alpine -- sleep 3600
kubetcl get pods -n mynamespace
