Tutorial link:
https://bolecodex.notion.site/K8SGPT-Kubernetes-SuperPowers-fef2dd8572c54d9db5fe504f799a24df?pvs=4

```
curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.9/k8sgpt_amd64.deb
sudo dpkg -i k8sgpt_amd64.deb

k8sgpt auth -p fake


k8sgpt auth --backend noopai --password sensitive
```