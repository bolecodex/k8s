Tutorial link:
https://bolecodex.notion.site/K8SGPT-Kubernetes-SuperPowers-fef2dd8572c54d9db5fe504f799a24df?pvs=4

```
curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.9/k8sgpt_amd64.deb
sudo dpkg -i k8sgpt_amd64.deb
k8sgpt generate
k8sgpt --help
k8sgpt auth add --backend openai -m gpt-3.5-turbo
kubectl apply -f broken-pod.yml
kubectl get pods
k8sgpt analyse --explain --backend openai
k8sgpt analyse --explain --backend openai --filter=Pod -l Chineses
kubectl apply -f deploy.yaml 
k8sgpt analyse --explain --backend openai
k8sgpt analyse --explain --backend openai --filter=Pod
k8sgpt analyze --explain --filter=Service --output=json
k8sgpt filters list
k8sgpt filters add NetworkPolicy
k8sgpt filters list
k8sgpt integrations list
```
