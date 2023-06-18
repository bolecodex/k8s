# Exercise
The Kubernetes client, `kubectl` is the primary method of interacting with a Kubernetes cluster. Getting to know it
is essential to using Kubernetes itself.


## Index
* [Syntax Structure](#syntax-structure)
* [Context and kubeconfig](#context-and-kubeconfig)
  * [kubectl config](#kubectl-config)
  * [Exercise: Using Contexts](#exercise-using-contexts)
* [kubectl Basics](#kubectl-basics)
  * [kubectl get](#kubectl-get)
  * [kubectl create](#kubectl-create)
  * [kubectl apply](#kubectl-apply)
  * [kubectl edit](#kubectl-edit)
  * [kubectl delete](#kubectl-delete)
  * [kubectl describe](#kubectl-describe)
  * [kubectl logs](#kubectl-logs)
  * [Exercise: The Basics](#exercise-the-basics)
* [Accessing the Cluster](#accessing-the-cluster)
  * [kubectl exec](#kubectl-exec)
  * [Exercise: Executing Commands within a Remote Pod](#exercise-executing-commands-within-a-remote-pod)
  * [kubectl proxy](#kubectl-proxy)
  * [Exercise: Using the Proxy](#exercise-using-the-proxy)
* [Cleaning up](#cleaning-up)
* [Helpful Resources](#helpful-resources)

---

# Syntax Structure

`kubectl` uses a common syntax for all operations in the form of:

```
kubectl <command> <type> <name> <flags>
```

* **command** - The command or operation to perform. e.g. `apply`, `create`, `delete`, and `get`.
* **type** - The resource type or object.
* **name** - The name of the resource or object.
* **flags** - Optional flags to pass to the command.

**Examples**
```
kubectl create -f mypod.yaml
kubectl get pods
kubectl get pod mypod
kubectl delete pod mypod
```

---

[Back to Index](#index)

---
---


# Context and kubeconfig
`kubectl` allows a user to interact with and manage multiple Kubernetes clusters. To do this, it requires what is known
as a context. A context consists of a combination of `cluster`, `namespace` and `user`.
* **cluster** - A friendly name, server address, and certificate for the Kubernetes cluster.
* **namespace (optional)** - The logical cluster or environment to use. If none is provided, it will use the default
`default` namespace.
* **user** - The credentials used to connect to the cluster. This can be a combination of client certificate and key,
username/password, or token.

These contexts are stored in a local yaml based config file referred to as the `kubeconfig`. For \*nix based
systems, the `kubeconfig` is stored in `$HOME/.kube/config` for Windows, it can be found in
`%USERPROFILE%/.kube/config`

This config is viewable without having to view the file directly.

**Command**
```
kubectl config view
```

**Example**
```yaml
❯ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://10.0.5.8:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED

```

---

### `kubectl config`

Managing all aspects of contexts is done via the `kubectl config` command. Some examples include:
* See the active context with `kubectl config current-context`.
* Get a list of available contexts with `kubectl config get-contexts`.
* Switch to using another context with the `kubectl config use-context <context-name>` command.
* Add a new context with `kubectl config set-context <context name> --cluster=<cluster name> --user=<user> --namespace=<namespace>`.

There can be quite a few specifics involved when adding a context, for the available options, please see the
[Configuring Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
Kubernetes documentation.

---

### Exercise: Using Contexts
**Objective:** Create a new context called `dev` and switch to it.

---

1. View the current contexts.
```
kubectl config get-contexts
```

2. Create a new context called `dev` within the `kubernetes` cluster with the `dev` namespace, as the
`dev` user.
```
kubectl config set-context dev --cluster=kubernetes --user=dev --namespace=dev
```

3. View the newly added context.
```
kubectl config get-contexts
```

4. Switch to the `kind-dev` context using `use-context`.
```
kubectl config use-context dev
```

5. View the current active context.
```
kubectl config current-context
```
6. return back to original context
```
kubectl config use-context kubernetes-admin@kubernetes
```

---

**Summary:** Understanding and being able to switch between contexts is a base fundamental skill required by every
Kubernetes user. As more clusters and namespaces are added, this can become unwieldy. Installing a helper
application such as [kubectx](https://github.com/ahmetb/kubectx) can be quite helpful. Kubectx allows a user to quickly
switch between contexts and namespaces without having to use the full `kubectl config use-context` command.

---

[Back to Index](#index)

---
---

## Kubectl Basics
There are several `kubectl` commands that are frequently used for any sort of day-to-day operations. `get`, `create`,
`apply`, `delete`, `describe`, and `logs`.  Other commands can be listed simply with `kubectl --help`, or
`kubectl <command> --help`.

---

### `kubectl get`
`kubectl get` fetches and lists objects of a certain type or a specific object itself. It also supports outputting the
information in several different useful formats including: json, yaml, wide (additional columns), or name
(names only) via the `-o` or `--output` flag.

**Command**
```
kubectl get <type>
kubectl get <type> <name>
kubectl get <type> <name> -o <output format>
```

**Examples**
```
> kubectl get namespaces
NAME          STATUS    AGE
default       Active    4h
kube-public   Active    4h
kube-system   Active    4h
> kubectl get pod mypod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE
mypod     1/1       Running   0          5m        172.17.0.6   cp
```

---

### `kubectl create`
`kubectl create` creates an object from the commandline (`stdin`) or a supplied json/yaml manifest. The manifests can be
specified with the `-f` or  `--filename` flag that can point to either a file, or a directory containing multiple 
manifests.

**Command**
```
kubectl create <type> <parameters>
kubectl create -f <path to manifest>
```

**Examples**
```
> kubectl create namespace dev
namespace "dev" created
```

---

### `kubectl apply`
`kubectl apply` is similar to `kubectl create`. It will essentially update the resource if it is already created, or
simply create it if does not yet exist. When it updates the config, it will save the previous version of it in an
`annotation` on the created object itself. **WARNING:** If the object was not created initially with
`kubectl apply` it's updating behavior will act as a two-way diff. For more information on this, please see the
[kubectl apply](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
documentation.

Just like `kubectl create` it takes a json or yaml manifest with the `-f` flag or accepts input from `stdin`.

**Command**
```
kubectl apply -f <path to manifest>
```

**Examples**
```
> kubectl apply -f mypod.yaml
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
pod "mypod" configured
```

---

### `kubectl edit`
`kubectl edit` modifies a resource in place without having to apply an updated manifest. It fetches a copy of the
desired object and opens it locally with the configured text editor, set by the `KUBE_EDITOR` or `EDITOR` Environment
Variables. This command is useful for troubleshooting, but should be avoided in production scenarios as the changes
will essentially be untracked.

**Command**
```
kubectl edit <type> <object name>
```

**Examples**
```
kubectl edit pod mypod
```

---

### `kubectl delete`
`kubectl delete` deletes the object from Kubernetes.

**Command**
```
kubectl delete <type> <name>
```

**Examples**
```
> kubectl delete pod mypod
pod "mypod" deleted
```

---

### `kubectl describe`
`kubectl describe` lists detailed information about the specific Kubernetes object. It is a very helpful
troubleshooting tool.

**Command**
```
kubectl describe <type>
kubectl describe <type> <name>
```

**Examples**
```
> kubectl apply -f mypod.yaml
> kubectl describe pod mypod
Name:             mypod
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Sun, 18 Jun 2023 21:37:48 +0000
Labels:           <none>
Annotations:      cni.projectcalico.org/containerID: 7d5c1d8564803acded6aa34d2556c1d430b5808e137e2610555753e735400c54
                  cni.projectcalico.org/podIP: 10.244.120.75/32
                  cni.projectcalico.org/podIPs: 10.244.120.75/32
Status:           Running
IP:               10.244.120.75
IPs:
  IP:  10.244.120.75
Containers:
  nginx:
    Container ID:   docker://d07cf09e51d540cbe2f8121bf72ada9b424e83a38b60d9b5639ed6c450e5d242
    Image:          nginx:stable-alpine
    Image ID:       docker-pullable://nginx@sha256:5e1ccef1e821253829e415ac1e3eafe46920aab0bf67e0fe8a104c57dbfffdf7
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sun, 18 Jun 2023 21:37:49 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-h4m96 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-h4m96:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  17s   default-scheduler  Successfully assigned default/mypod to minikube
  Normal  Pulled     16s   kubelet            Container image "nginx:stable-alpine" already present on machine
  Normal  Created    16s   kubelet            Created container nginx
  Normal  Started    16s   kubelet            Started container nginx
  ```

---

### `kubectl logs`
`kubectl logs` outputs the combined `stdout` and `stderr` logs from a pod. If more than one container exist in a
`pod` the `-c` flag is used and the container name must be specified.

**Command**
```
kubectl logs <pod name>
kubectl logs <pod name> -c <container name>
```

**Examples**
```
kubectl logs mypod
2023/06/18 21:37:49 [notice] 1#1: using the "epoll" event method
2023/06/18 21:37:49 [notice] 1#1: nginx/1.24.0
2023/06/18 21:37:49 [notice] 1#1: built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r4) 
2023/06/18 21:37:49 [notice] 1#1: OS: Linux 5.15.0-1036-aws
2023/06/18 21:37:49 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/06/18 21:37:49 [notice] 1#1: start worker processes
2023/06/18 21:37:49 [notice] 1#1: start worker process 31
2023/06/18 21:37:49 [notice] 1#1: start worker process 32
```

---

### Exercise: The Basics
**Objective:** Explore the basics. Create a namespace, a pod, then use the `kubectl` commands to describe and delete
what was created.

**NOTE:** You should still be using the `kind-dev` context created earlier.

---

1) Create the `dev` namespace.
```
kubectl create namespace dev
```

2) Apply the manifest `mypod.yaml`.
```
kubectl apply -f mypod.yaml
```

3) Get the yaml output of the created pod `mypod`.
```
kubectl get pod mypod -o yaml
```

4) Describe the pod `mypod`.
```
kubectl describe pod mypod
```

5) Clean up the pod by deleting it.
```
kubectl delete pod mypod
```

---

**Summary:** The `kubectl` _"CRUD"_ commands are used frequently when interacting with a Kubernetes cluster. These
simple tasks become 2nd nature as more experience is gained.

---

[Back to Index](#index)

---
---

# Accessing the Cluster

`kubectl` provides several mechanisms for accessing resources within the cluster remotely. For this tutorial, the focus
will be on using `kubectl exec` to get a remote shell within a container, and `kubectl proxy` to gain access to the
services exposed through the API proxy.

---

### `kubectl exec`
`kubectl exec` executes a command within a Pod and can optionally spawn an interactive terminal within a remote
container. When more than one container is present within a Pod, the `-c` or `--container` flag is required, followed
by the container name.

If an interactive session is desired, the `-i` (`--stdin`) and `-t` (`--tty`) flags must be supplied.

**Command**
```
kubectl exec <pod name> -- <arg>
kubectl exec <pod name> -c <container name> -- <arg>
kubectl exec  -i -t <pod name> -c <container name> -- <arg>
kubectl exec  -it <pod name> -c <container name> -- <arg>
```


**Example**
```
> kubectl apply -f mypod.yaml
> kubectl exec mypod -c nginx -- printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=mypod
NEWDEP_PORT=tcp://10.111.246.183:8080
NGINXSVC_SERVICE_PORT=80
NGINXSVC_PORT_80_TCP=tcp://10.105.15.62:80
NGINXSVC_PORT_80_TCP_PORT=80
NEWDEP_SERVICE_HOST=10.111.246.183
NEWDEP_PORT_8080_TCP_PORT=8080
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
NGINXSVC_PORT_80_TCP_ADDR=10.105.15.62
NEWDEP_PORT_8080_TCP=tcp://10.111.246.183:8080
NEWDEP_PORT_8080_TCP_ADDR=10.111.246.183
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT_HTTPS=443
NGINXSVC_SERVICE_HOST=10.105.15.62
NGINXSVC_PORT=tcp://10.105.15.62:80
NGINXSVC_PORT_80_TCP_PROTO=tcp
NEWDEP_SERVICE_PORT=8080
NEWDEP_PORT_8080_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
NGINX_VERSION=1.24.0
PKG_RELEASE=1
NJS_VERSION=0.7.12
HOME=/root

> kubectl exec -i -t mypod -c nginx -- /bin/sh
/ #
/ # cat /etc/alpine-release
3.17.4
/ # exit
```

---

### Exercise: Executing Commands within a Remote Pod
**Objective:** Use `kubectl exec` to both initiate commands and spawn an interactive shell within a Pod.

---

1) If not already created, create the Pod `mypod` from the manifest `mypod.yaml`.
```
kubectl apply -f mypod.yaml
```

2) Wait for the Pod to become ready (`running`).
```
kubectl get pods
```

3) Use `kubectl exec` to `cat` the file `/etc/os-release`.
```
kubectl exec mypod -- cat /etc/os-release
```
It should output the contents of the `os-release` file.

4) Now use `kubectl exec` and supply the `-i -t` flags to spawn a shell session within the container.
```
kubectl exec -i -t mypod -- /bin/sh
```
If executed correctly, it should drop you into a new shell session within the nginx container.

5) use `ps aux` to view the current processes within the container.
```
/ # ps aux
```
There should be two nginx processes along with a `/bin/sh` process representing your interactive shell.

6) Exit out of the container simply by typing `exit`.
```
/ # exit
```
With that the shell process will be terminated and the only running processes within the container should
once again be nginx and its worker process.

---

**Summary:** `kubectl exec` is not often used, but is an important skill to be familiar with when it comes to Pod
debugging.

---

### `kubectl proxy`
`kubectl proxy` enables access to both the Kubernetes API-Server and to resources running within the cluster
securely using `kubectl`. By default it creates a connection to the API-Server that can be accessed at
`127.0.0.1:8001` or an alternative port by supplying the `-p` or `--port` flag.


**Command**
```
kubectl proxy
kubectl proxy --port=<port>
```

**Examples**
```
> kubectl proxy
Starting to serve on 127.0.0.1:8001

<from another terminal>
curl 127.0.0.1:8001/version
{
  "major": "",
  "minor": "",
  "gitVersion": "v1.9.0",
  "gitCommit": "925c127ec6b946659ad0fd596fa959be43f0cc05",
  "gitTreeState": "clean",
  "buildDate": "2018-01-26T19:04:38Z",
  "goVersion": "go1.9.1",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

The Kubernetes API-Server has the built in capability to proxy to running services or pods within the cluster. This
ability in conjunction with the `kubectl proxy` command allows a user to access those services or pods without having
to expose them outside of the cluster.

```
http://<proxy_address>/api/v1/namespaces/<namespace>/<services|pod>/<service_name|pod_name>[:port_name]/proxy
```
* **proxy_address** - The local proxy address - `127.0.0.1:8001`
* **namespace** - The namespace owning the resources to proxy to.
* **service|pod** - The type of resource you are trying to access, either `service` or `pod`.
* **service_name|pod_name** - The name of the `service` or `pod` to be accessed.
* **[:port]** - An optional port to proxy to. Will default to the first one exposed.

**Example**
```
http://127.0.0.1:8001/api/v1/namespaces/default/pods/mypod/proxy/
```

---

### Exercise: Using the Proxy
**Objective:** Examine the capabilities of the proxy by accessing a pod's exposed ports.

---

1) Create the Pod `mypod` from the manifest `mypod.yaml`. (if not created previously)
```
kubectl apply -f mypod.yaml
```

2) Start the `kubectl proxy` with the defaults.
```
kubectl proxy
```

3) Access the Pod through the proxy.
```
curl http://127.0.0.1:8001/api/v1/namespaces/default/pods/mypod/proxy/
```
You should see the "Welcome to nginx!" page.

---

**Summary:** Being able to access the exposed Pods and Services within a cluster without having to consume an
external IP, or create firewall rules is an incredibly useful tool for troubleshooting cluster services.

---

[Back to Index](#index)

---
---

## Cleaning up
**NOTE:** If you are proceeding with the next tutorials, simply delete the pod with:
```
kubectl delete pod mypod
```
The namespace and context will be reused. 

To remove everything that was created in this tutorial, execute the following commands:
```
kubectl delete namespace dev
kubectl config delete-context dev
```

---

[Back to Index](#index)

---
---

### Helpful Resources
* [kubectl Overview](https://kubernetes.io/docs/reference/kubectl/overview/)
* [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [kubectl Reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
* [Accessing Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/)


[Back to Index](#index)
