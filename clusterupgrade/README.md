# Demo: Cluster upgrade

1. apt update

```
sudo apt update
```

##

2. Check the list of available kubeadm packages (in madison form)

```
sudo apt-cache madison kubeadm
```

##

3.kubeadm hold removed, installed with version 1.27.0

```
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.27.0-00
```

##

4. hold kubeadm again

```
sudo apt-mark hold kubeadm
```

##

5. Check the kubeadm version

```
sudo kubeadm version
```

##

6. Remove scheduling (pod deployment) functionality to cp nodes, (to update cp nodes, you must first remove as many pods as possible).

```
kubectl drain <node-to-drain> --ignore-daemonsets
# you can run "kubectl get nodes" to ge the node name <node-to-drain> 
```

##

7.kubeadm Check upgrade plan

```
sudo kubeadm upgrade plan
```

##

8. Run kubeadm upgrade (enter y when prompted to continue upgrading)

```
sudo kubeadm upgrade apply v1.25.1
```

##

9. Check node status. (Check Disable CP Schedule)

```
kubectl get nodes
```

##

10.kubelet, kubectl 언포드

```
sudo apt-get unhold kubelet kubectl
```

##

11.Install kubelet and kubectl according to the kubeadm version

```
sudo apt-get install -y cube=1.25.1-00 cubectl=1.25.1-00
```

##

12. kubelet, kubectl hold

```
sudo apt-get mark hold kubelet kubectl
```

##

13. Restart the daemon

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

##

14. Check CP node new version

```
kubectl get nodes
```

##

15. Re-enable scheduler to use CP

```
kubectl uncordon cp
```

##

16. Check CP node Ready status

```
kubectl get nodes
```

##

17. Remove kubeadm hold from Worker node, install with version 1.24.1

```
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.25.1-00
```

##

18. Hold kubeadm again

```
sudo apt-mark hold kubeadm
```

##

19. Add option to ignore daemonset from CP node to worker node

```
kubectl drain worker --ignore-daemonsets
```

##

20.Upgrade on worker node

```
sudo kubeadm upgrade node
```

##

21. kubelet, kubectl 언포드

```
sudo apt-get unhold kubelet kubectl
```

##

22.Install kubelet and kubectl according to the kubeadm version

```
sudo apt-get install -y cube=1.25.1-00 cubectl=1.25.1-00
```

##

23. kubelet, kubectl hold

```
sudo apt-get mark hold kubelet kubectl
```

##

24. Restart the daemon

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

##

25. Check worker node status on CP node

```
kubectl get nodes
```

##

26. Set the scheduler to use the worker again

```
kubectl uncordon worker
```

##

27.Check node's Ready status and version

```
kubectl get nodes
```
