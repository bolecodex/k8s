# Task
Find the Pod with the highest CPU load and write its name to the file /var/exam/cpu-pods.txt
# Solution
```
kubectl top pod --all-namespaces --sort-by='cpu' | awk 'NR==2{print $2}' >> /var/exam/cpu-pods.txt
# or
kubectl top pod -A --sort-by cpu --no-headers | head -1 | awk '{print $2}' >> /var/exam/cpu-pods.txt
```

# Exercise 13.3

>Metric-Server

1. Metric-Server Installation
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

##

2. Modify the deployed Metric-server Deployment
```
kubectl -n kube-system edit deploy metrics-server
```
Add below values to spec.template.spec.containers.args

```
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
```
```
kubectl –n kube-system logs metrics-server<TAB> 
```
should show "Generating self-signed cert" and "Serving securely on [::]443

##

3. Check node resource usage
```
kubectl top node
```
Pod modified in 2 must be in Running state again to operate.

##

>Dashboard Configuration

1. Download the kubernetes dashboard chart
```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm fetch kubernetes-dashboard/kubernetes-dashboard --untar
cd kubernetes-dashboard && ls
```

2. Check values.yaml
```
cat values.yaml
```

##

3.Kubernetes Dashboard chart installation
```
helm install kubernetes-dashboard . --set service.type=NodePort
```

##

4. Check the installed Service Account
```
kubectl get to kubernetes-dashboard
```

##

5. Set the admin role to the SA checked above
```
kubectl create clusterrolebinding dashaccess \
--clusterrole=cluster-admin \
--serviceaccount=default:kubernetes-dashboard
```

##

6. Create a Secret to connect to the above SA
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: secret-dashboard
  annotations:
    kubernetes.io/service-account.name: "kubernetes-dashboard"
type: kubernetes.io/service-account-token
EOF
```

##

7. Check the secret token above (save in notepad)
```
kubectl describe secret <secret name>
```

##

8. Check Service Nodeport
```
kubectl get svc kubernetes-dashboard
```

##

9. Connect to the address below in your web browser
```
<Node IP>:<SVC NodePort>
```

above address verification command
```
echo "https://$(curl -s ifconfig.io):$(kubectl get svc kubernetes-dashboard -o=jsonpath='{.spec.ports[?(@.port==443)].nodePort}')"
```

If a certificate error occurs, enter thisisunsafe in Chrome browser
##

Log in using the token value saved in step 10.7

##

11. Delete resource
```
kubectl delete clusterrolebinding dashaccess
helm uninstall kubernetes-dashboard
cd
```
