# Exercise 9.3


1.Pod Creation
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: free
spec:
  containers:
  - name: free
    image: ubuntu:latest
    command: [ "sleep" ]
    args: [ "infinity" ]
EOF
```

##

2. Connect to Pod
```
kubectl exec -it ubuntu -- /bin/bash
```

##

3. Install the package to check the network
```
apt-get update ; apt-get install curl dnsutils -y
```

##

4. Root name server, DNS server check
```
dig
```

##

5. Determine which nameservers to search using the FQDN and the default domain
```
cat /etc/resolv.conf
```

##

6. Check the detailed information of the DNS server
```
you @10.96.0.10 -x 10.96.0.10
```

##

7. Run curl with the FQDN of the Service created in the previous section
```
curl service-lab.accounting.svc.cluster.local.
```

##

8.Curl only with Service name (failed because nettool is only in Default)
```
curl service-lab
```

##

9. Add NS to curl
```
curl service-lab.accounting
```

##

10. Pod disconnection
```
exit
```

##

11.Check the service running in kube-system NS
```
kubectl -n kube-system get svc
```

##

12. Print detailed information
```
kubectl -n kube-system get svc kube-dns -o yaml
```

##

13.Output pod with label k8s-app on all NS
```
kubectl get pod -l k8s-app --all-namespaces
```

##

14. Check the details of one of the coreDNS pods
```
kubectl -n kube-system get pod <coreDNS pod name> -o yaml
```
Confirm that configuration comes from Configmap

##

15.Check the configmap in kube-system NS
```
kubectl -n kube-system get configmap
```

##

16. Check the coredns Configmap details
```
kubectl -n kube-system get configmaps coredns -o yaml
```

Check the cluster.local domain

##

17. Coredns Configmap modification
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        rewrite name regex (.*)\.example\.com {1}.default.svc.cluster.local
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
EOF
```

##

18.Delete the coredns Pod to configure redeployment
```
kubectl -n kube-system delete pod <coredns pod name> <other coredns pod name>
```

##

19.Deployment creation and service creation
```
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=ClusterIP --port=80
```

##

20.Check the created service
```
kubectl get svc
```

##

21. Connect to the alpine container
```
kubectl exec -it alpine -- /bin/bash
```

##

22. DNS address search with the IP address of the service created above
```
dig -x <above svc ip>
```

##

23. Reverse lookup test
```
dig nginx.default.svc.cluster.local.
```

##

24. Test.io tests added to Coredns
```
dig nginx.test.io
```

##

25.pod connection termination
```
exit
```

##

26. Edit the configmap
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        rewrite stop {
            name regex (.*)\.example\.com {1}.default.svc.cluster.local
            answer name (.*)\.default\.svc\.cluster\.local {1}.example.com
        }
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
EOF
```

##

27.Configure redeployment by deleting the pod
```
kubectl -n kube-system delete pod <coredns pod name> <other corends pod name>
```

##

28.Connect to Pod again
```
kubectl exec -it alpine -- /bin/bash
```

##

29.test.io test
```
dig nginx.test.io
```

##

30. Pod disconnection
```
exit
```

##

31.Delete the alpine pod
```
kubectl delete pod alpine
```