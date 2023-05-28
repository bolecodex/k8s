# Exercise 15.1


1.Check the kubelet configuration file path
```
systemctl status kubelet.service
```

##

2. Check the kubelet config file
```
sudo cat /var/lib/kubelet/config.yaml
```

##

3.CP component check
```
sudo ls /etc/kubernetes/manifests/
```

##

4.Check the certificate-related settings set in the kube-controller-manager.yaml file
```
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml
```

##

5. Check Secret in kube-system NS
```
kubectl -n kube-system get secrets
```

##

6.Check the details of certificate-controller-token among Tokens of Secret
```
kubectl -n kube-system get secrets -o yaml certificate-controller <tap key input>
```

##

7.kubeconfig check
```
kubectl config view
```

##

8.kubeconfig source check
```
cat ~/.kube/config
```

##

9.kubeconfig clone (to be used in the next step)
```
cp $HOME/.kube/config $HOME/cluster-api-config
```

##

10. Check help for each command

```
kubectl config -h
kubeadm token -h
kubeadm config -h
```

##

11. Check the cluster default settings
```
sudo kubeadm config print init-defaults
```