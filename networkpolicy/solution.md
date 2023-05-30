# Task 1
Create a NetworkPolicy that applies to the namespace npdemo and provides access only to pods that are running nginx and which are running in that namespace. Only pods coming from the default namespace provided with the label access=allowed should be allowed access
# Solution
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mynp
  namespace: npdemo
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              namespace: default
          podSelector:
            matchLabels:
              access: allowed
```
