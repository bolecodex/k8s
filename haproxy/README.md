# Exercise

1.HAProxy node connection

```
ssh -i LFS458.pem <HAproxy node ip>
```

##

2. Change the hostname with the corresponding command

```
sudo -i
sudo hostnamectl set-hostname haproxy
sudo -i
```

##

3.haproxy installation

```
sudo apt-get update && sudo apt-get install -y haproxy
```

##

4. Modify the /etc/haproxy/haproxy.cfg file

```
vi /etc/haproxy/haproxy.cfg
```

Modify near line 23 like below

```
defaults
	log	global
	mode	tcp
	option	tcplog
```

Add the line below (enter your own CP IP in CP IP)

```
frontend proxynode
   bind *:80
   bind *:6443
   stats uri /proxystats
   default_backend k8sServers

backend k8sServers
   balance roundrobin
   server cp1 <CP IP>:6443 check  

listen stats
     bind :9999
     mode http
     stats enable
     stats hide-version
     stats uri /stats
```

##

5. HAproxy daemon restart

```
sudo systemctl restart haproxy
sudo systemctl status haproxy --no-pager
```

##

6. Modify /etc/hosts file in CP node terminal

```
sudo vi /etc/hosts
```

Change the ip address of k8scp to haproxy ip

```
<haproxy ip> k8scp
```

##

7. Modify /etc/hosts file in worker node terminal

```
sudo vi /etc/hosts
```

Change the ip address of k8scp to haproxy ip

```
<haproxy ip> k8scp
```

##

8. Connect to the address below in a web browser

```
<haproxy ip>:9999/stats
```

ip check command

```
curl ifconfig.io
```



9. API call from CP node terminal

```
kubectl get node
kubectl get pod -A
```

##

10. Refresh the HAproxy statistics page to check if the traffic information (Byte traffic of Proxynode) is updated.

##

11.CP2 Node Connection

```
ssh -i LFS458.pem <CP2 node ip>
```

##

12. Change the hostname with the corresponding command

```
sudo -i
sudo hostnamectl set-hostname k8scp2
sudo -i
```

##

13. Pre-installation same as the previous cp configuration (container runtime + kubernetes installation)
```
apt-get update && apt-get upgrade -y
```
```
apt install curl apt-transport-https vim git wget gnupg2 software-properties-common apt-transport-https ca-certificates uidmap lsb-release -y
```

```
swapoff -a
```

```
modprobe overlay
modprobe br_netfilter
```


```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
```

```
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/kubernetes-xenial main
EOF
```

```
curl -s \
https://packages.cloud.google.com/apt/doc/apt-key.gpg \ | apt-key add -
```

```
apt-get update
```

```
apt-get install -y kubeadm=1.25.1-00 kubelet=1.25.1-00 kubectl=1.25.1-00
```

```
apt-mark hold kubelet kubeadm kubectl
```

```
sed -i '/"cri"/ s/^/#/' /etc/containerd/config.toml
```
```
systemctl restart containerd
```

14. Update the /etc/hosts file

```
sudo echo <HAporxy IP> k8scp >> /etc/hosts
```

##

15.CP3 Node Connection

```
ssh -i LFS458.pem <CP3 node ip>
```

##

16. Change the hostname with the corresponding command

```
sudo -i
sudo hostnamectl set-hostname k8scp3
sudo -i
```

Step 17.13\~14

##

18. Token generation at CP node terminal

```
sudo kubeadm token create
```

##

19.SSL hash generation

```
openssl x509 -pubkey \
 -in /etc/kubernetes/pki/ca.crt | openssl rsa \
 -pubin -outform der 2>/dev/null | openssl dgst \
 -sha256 -hex | sed 's/ˆ.* //'
```

##

20.Generate a new CP node certificate

```
sudo kubeadm init phase upload-certs --upload-certs
```

##

21. New CP2,3 join command combination

```
sudo kubeadm join k8scp:6443 --control-plane \
--token <token of course 18> \
--discovery-token-ca-cert-hash sha256:<19과정의 ssl hash> \
--certificate-key <20 course certs>
```

##

Execute the command combined in 22.21 on cp2 node and cp3 node



(Troubleshooting errors when joining)

error execution phase preflight: \[preflight] Some fatal errors occurred:

&#x20;   \[ERROR FileContent--proc-sys-net-ipv4-ip\_forward]: /proc/sys/net/ipv4/ip\_forward contents are not set to \~

Rejoin after entering the command below

```
echo '1' > /proc/sys/net/ipv4/ip_forward
```

(Troubleshooting errors when joining 2)

error execution phase preflight: \[preflight] Some fatal errors occurred:&#x20;

\[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist \[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`

Rejoin after entering the command below

```
modprobe br_netfilter

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
```





> Run steps 23\~25 on both nodes cp2 and cp3.

23. Switch to ubuntu user

```
exit
```

##

24. Create kubeconfig file

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

##

25. Added command auto-completion function

```
echo 'source <(kubectl completion bash)' >>~/.bashrc
source <(kubectl completion bash)
```

##

26.Go to the HAProxy node and modify the configuration file

```
vi /etc/haproxy/haproxy.cfg
```

```
backend k8sServers
   balance roundrobin
   server cp1 <CP1 ip>:6443 check
   server cp2 <CP2 ip>:6443 check
   server cp3 <CP3 ip>:6443 check
```

##

27.HAproxy daemon restart

```
sudo systemctl restart haproxy
sudo systemctl status haproxy --no-pager
```

##

28. Go to :9999/stats in a web browser and check the connection status of the added nodes

##

29. Check Node list in CP node

```
kubectl get nodes
```

##

30.Execute api call using kubectl command and check load distribution on haproxy statistics site

```
for i in {1..10}; do kubectl get pod; done
```



31. Check running etcd Pod

```
kubectl get pod -n kube-system -l component=etcd
```



32. Check the ETCD Pod log

```
kubectl -n kube-system logs etcd-k8scp2 | grep leader -A 5 -B 5
```



33. Check the IP address of the running ETCD Pod

```
kubectl get pod -n kube-system -l component=etcd -o wide 
```



34. Check ETCD cluster status

```
kubectl -n kube-system exec -it etcd-cp -- \
etcdctl -w table \
--endpoints \
$(kubectl get pod etcd-cp -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp2 -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp3 -n kube-system -o=jsonpath='{.status.podIP}'):2379 \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
endpoint status
```



35. Stop container on CP node

```
sudo systemctl stop kubelet
sudo crictl stop $(sudo crictl ps -q)
sudo systemctl stop containerd
sudo systemctl start kubelet
```



36. Check the ETCD Pod log

```
kubectl -n kube-system logs etcd-k8scp2 | grep leader -A 5 -B 5
```



37. Refresh the HAProxy web browser dashboard to check the node connection status



38. Check the ETCD cluster status on the other CP nodes - confirm that the leader has changed

```
kubectl -n kube-system exec -it etcd-k8scp2 -- \
etcdctl -w table \
--endpoints \
$(kubectl get pod etcd-cp -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp2 -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp3 -n kube-system -o=jsonpath='{.status.podIP}'):2379 \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
endpoint status
```



39.NODE Status Check

```
kubectl get nodes
```

Rerun container runtime on CP node

```
sudo systemctl start containerd
```



40.Check all pods are running normally

```
kubectl get pod -A
```



41. Check ETCD cluster status

```
kubectl -n kube-system exec -it etcd-k8scp2 -- \
etcdctl -w table \
--endpoints \
$(kubectl get pod etcd-cp -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp2 -n kube-system -o=jsonpath='{.status.podIP}'):2379,\
$(kubectl get pod etcd-k8scp3 -n kube-system -o=jsonpath='{.status.podIP}'):2379 \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
endpoint status
```
