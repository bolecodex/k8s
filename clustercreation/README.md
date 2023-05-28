# Exercise 3.0 - presetting

> Practice environment - composed of AWS EC2 virtual machine environment

Control Plane (Master Node)

```
OS : Ubuntu 20.04
vCPU : 2
Memory : 8G
HDD or SSD : 20G
```

Data Plane (Worker Node)

```
OS : Ubuntu 20.04
vCPU : 2
Memory : 8G
HDD or SSD : 20G
```

##

> Practice Materials (YAML)

```
Download path: https://training.linuxfoundation.org/cm/LFS458
user : LFtraining
password : Penguin2014

or download the file provided by the instructor
```

##

> Workspace settings

1. Log in to AWS with the provided account

```
aws access link:
https://gkcloudps.signin.aws.amazon.com/console
```

![](../img/awslogin.png)

##

2. Search for Cloud9 in the search bar at the top and click Cloud9 service

![](../img/cloud9.png)

##

3. Click Create environment

![](../img/create.png)

##

4. Enter your account name in the Name field and click Next step

![](../img/name.png)

##

5.Select t3.small, ubuntu 18.04 as shown in the screenshot below and click Next step

![](../img/t3.png)

![](../img/ubuntu.png)

##

6.Review the entered information and click Create environment

![](../img/next.png)

##

7. Upload the provided pem file by clicking File - Upload Local Files at the top left in the Cloud environment

![](../img/uploadfile.png)

![](../img/key.png)

##

8. Change the authority of the key file with the corresponding command

```
chmod 600 LFS458.pem
```

##

9. Connect to the CP node with the command

```
ssh -i LFS458.pem <CP IP>
```

##

10. Change the hostname with the corresponding command

```
sudo -i
sudo hostnamectl set-hostname cp
sudo -i
```

##

11. Click the + button and open a new terminal.

![](../img/terminal.png)

##

12.Connect to the worker node with the command

```
ssh -i LFS458.pem <worker ip>
```

##

13. Change the hostname with the corresponding command

```
sudo -i
sudo hostnamectl set-hostname worker
sudo -i
```

# Exercise 3.1 - Install Kubernetes

> Proceed in Control Plane

1. Change to root user

```
sudo -i
```

##

2. Package tool (apt) update

```
apt-get update && apt-get upgrade -y
```

##

3. Install required packages to ensure dependencies

```
apt install curl apt-transport-https vim git wget gnupg2 software-properties-common apt-transport-https ca-certificates uidmap lsb-release -y
```

##

4. Disable Swap

```
swapoff -a
```

##

5. Module loading

```
modprobe overlay
modprobe br_netfilter
```

##

6.Update kernel networking to allow required traffic

```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

##

7. Make sure your changes are also used in the current kernel

```
sysctl --system
```

![](../img/sysctl.png)

omitted below

##

8.containerd installation
```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
```

##

9.apt-get add repository

```
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/kubernetes-xenial main
EOF
```

##

10. Add GPG key for package

```
curl -s \
https://packages.cloud.google.com/apt/doc/apt-key.gpg \ | apt-key add -
```

##

11.apt-get update

```
apt-get update
```

##

12.Install kubernetes software (will be updated to the latest version later in the lab)

```
apt-get install -y kubeadm=1.24.1-00 kubelet=1.24.1-00 kubectl=1.24.1-00
```

##

13.holding installed kubernetes software
```
apt-mark hold kubelet kubeadm kubectl
```

##

14. Check the IP address of the CP server

```
hostname -i
```

##

15. Update /etc/hosts

```
echo <CP IP> k8scp >> /etc/hosts
```

##

16. Create kubeadm-config.yaml file

```
cat << EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.24.1
controlPlaneEndpoint: "k8scp:6443"
networking:
  podSubnet: 172.16.0.0/16
EOF
```

##

17. CP initialization

```
kubeadm init --config=kubeadm-config.yaml --upload-certs \
| tee kubeadm-init.out
```
>When container runtime operation error occurs
```
sed -i '/"cri"/ s/^/#/' /etc/containerd/config.toml
```

##

18. Convert to regular user (ubuntu)

```
exit
```

##

19.Create and configure kubeconfig file

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

##

20.Flannel Network Plugin Installation
```
kubectl create -f https://raw.githubusercontent.com/wsjang619/k8s_course/master/lab1/yaml/flannel.yaml
```

Reference link : https://github.com/flannel-io/flannel


##

21.kubectl command autocompletion setting

```
sudo apt-get install bash-completion -y
```

```
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
source /etc/bash_completion
echo alias k=kubectl >> ~/.bashrc
source ~/.bashrc
complete -F __start_kubectl k
```


# Exercise 3.2 - Grow the Cluster

> Proceed on Worker Node

1. Change to root user

```
sudo -i
```

##

2. Proceed in the same way as steps 2 to 15 of EX 3.1


##


3. Create join command in CP terminal

```
kubeadm token create --print-join-command --ttl 0
```

##

4.Execute the command resulting from the 14 commands in the Worker terminal

```
Created with kubeadm join ~~~
```

##

5. Attempt to execute kubectl command in Worker terminal
```
kubectl get node
```
> An error occurs because there are no config and authentication files in the kubernetes cluster, kubectl (control command) is executed on the cp node
> 
> 
# Exercise 3.3 - Finish Cluster Setup

> Proceed in Control Plane

1. Check the nodes registered in the cluster

```
kubectl get node
```

##

2. Inquiry of detailed information of CP node

```
kubectl describe node cp
```

##

3. CP node taint check

```
kubectl describe node | grep -i taint
```

##

3. CP node taint deletion

```
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

##

4.Check that both coredns-pod and plannel-pod are in Running state (takes 1-2 minutes)

```
kubectl get pods --all-namespaces
```

Even after 3-4 minutes, if it is in the ContainerCreating stage, the Pod is deleted and redeployed.

```
kubectl -n kube-system delete pod <your pod name>
```

##

5.Check the added flannel interface

```
ip a
```

![](../img/flannel-int.png)

##

6.containerd configuration update
```
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
```

# Exercise 3.4 - Deploy A Simple Application

> Proceed in Control Plane

1.Deployment

```
kubectl create deployment nginx --image=nginx
```

##

2.Deployment inquiry

```
kubectl get deployment
```

##

3.Deployment detailed inquiry

```
kubectl describe deployment
```

##

4.Check the basic steps taken to import and deploy a new application in the cluster

```
kubectl get events
```

##

Deployment output in 5.yaml format

```
kubectl get deployment nginx -o yaml
```

##

6. Convert to file

```
kubectl get deployment nginx -o yaml > first.yaml
```

##

7. Delete the status field

```
vi first.yaml
```
delete below
```
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2023-
    lastUpdateTime: "2023-
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2023-
    lastUpdateTime: "2023-
    message: ReplicaSet "nginx-8f458dc5b" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
```
##

8. Delete the existing Deployment

```
kubectl delete deployment nginx
```

##

9. Create Deployment based on modified yaml

```
kubectl create -f first.yaml
```

##

10. Convert Deployment to yaml file again

```
kubectl get deployment nginx -o yaml > second.yaml
```

##

11. Compare two files

```
diff first.yaml second.yaml
```

##

12.Execute command to confirm creation of Deployment (actual deployment will not occur if --dry-run option is used)

```
kubectl create deployment two --image=nginx --dry-run=client -o yaml
```

##

13.deployment confirmation

```
kubectl get deployment
```

##

Output in 14.yaml format

```
kubectl get deployment nginx -o yaml
```

##

15. Output in json format

```
kubectl get deployment nginx -o json
```

##

16. Create a service to view the default page

```
kubectl expose deployment/nginx
```
>Error Occurred

##

17. Modify the first.yaml file

```
vi first.yaml
```

Add spec.containers.ports entry

```
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx
    ports:                  # This
    - containerPort: 80     # three
      protocol: TCP         # line
```

metadata.creationTimestamp

metadata.uid

metadata.resourceVersion

Delete 3 items

##

18. Redeploy after deleting the existing Deployment with the modified contents

```
kubectl replace -f first.yaml
```

##

19. Search for newly deployed Deployments and Pods

```
kubectl get deploy,pod
```

##

20. Create service again

```
kubectl expose deployment/nginx
```

##

21. Check service

```
kubectl get svc nginx
```

##

22.endpoint check

```
kubectl get ep nginx
```

##

23.Check which node the pod is configured on and the IP of that node

```
kubectl describe pod <pod name> | grep Node:
```

##


25. Test access to ClusterIP:80 from CP node

```
curl <ClusterIP>:80
```

##

26. Access test with endpoint

```
curl <endpointIP>:80
```

##

27.Deployment Environment Expand web server from 1 to 3

```
kubectl get deployment nginx
kubectl scale deployment nginx --replicas=3
kubectl get deployment nginx
```

##

28. Check the endpoint again

```
kubectl get ep nginx
```

##

Pod lookup in 29.wide format

```
kubectl get pod -o wide
```

##

30.Delete the oldest Pod

```
kubectl delete pod <oldest pod name>
```

##

31.Pod recheck

```
kubectl get pod
```

##

32.Check the endpoint again

```
kubectl get ep nginx
```

##

33. Re-test access to ClusterIP:80 from the CP node (even if the endpoint is changed, access to the web server is possible)

```
curl <ClusterIP>:80
```


# Exercise 3.5


> Proceed in Control Plane

1.Pod check

```
kubectl get pod
```
##

2.Select one of the pods and run the printenv command in the pod with the exec command

```
kubectl exec <pod name> -- printenv | grep KUBERNETES
```

##

3. Delete nginx svc
```
kubectl get svc
kubectl delete svc nginx
```

##

4. Create loadbalancer type svc (externalIP is pending)

```
kubectl expose deployment nginx --type=LoadBalancer
```

##

5.Check Nodeport by querying svc information (expressed as portnumber:Nodeport/tcp)
```
kubectl get svc
```

##

6. Check the public IP of the node

```
curl ifconfig.io
```

##

7. Open a web browser and try to access the Public IP and NodePort above.
```
<PublicIP>:<NodePort>
```
![](../img/nginx.png)

##

8. Scale the deployment's replicas to 0
```
kubectl scale deployment nginx --replicas=0
kubectl get pod
```

##

9. Refresh in web browser

##

10. Scale the deployment's replicas to 2
```
kubectl scale deployment nginx --replicas=2
kubectl get pod
```

##

11. Refresh the web browser again to check the web server

##

12.Deployment deletion, Endpoint deletion, svc deletion
```
kubectl delete deployment nginx
kubectl delete ep nginx
kubectl delete svc nginx
```