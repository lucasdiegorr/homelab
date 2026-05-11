# homelab

Infrastructure-as-code for k3s homelab.

## Structure

```
kubernetes/     # K8s manifests (GitOps via ArgoCD/Flux)
terraform/     # Infrastructure definitions
ansible/       # Configuration management
```

## Services

| Service | URL |
|---------|-----|
| ArgoCD | http://192.168.0.100/argocd |
| Portainer | http://192.168.0.100/portainer |
| NextCloud | http://192.168.0.100/nextcloud |

### ArgoCD Access
- **User**: admin
- **Password**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## Deploying Changes

1. **Kubernetes**: Push to git, ArgoCD auto-syncs
2. **Terraform**: Run `terraform init` && `terraform apply` locally
3. **Ansible**: Run `ansible-playbook` against inventory

## Initial Setup

1. Install ArgoCD: `helm install argocd argo/argo-cd -n argocd -f kubernetes/argocd/argocd-helm-values.yaml`
2. Push code to GitHub
3. Apply Application: `kubectl apply -f kubernetes/argocd-application.yaml`