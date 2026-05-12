# Homelab

Infrastructure-as-code for k3s homelab managed via GitOps.

## Structure

```
kubernetes/     # K8s manifests (GitOps via ArgoCD)
terraform/      # Infrastructure definitions
ansible/        # Host configuration
```

## Services

| Service  | URL                              | Description              |
|----------|----------------------------------|--------------------------|
| ArgoCD   | http://192.168.0.100/argocd/    | GitOps controller       |
| Nextcloud| http://192.168.0.100/nextcloud/ | Cloud storage           |

### ArgoCD Access

- **URL**: http://192.168.0.100/argocd/
- **Username**: admin
- **Password**:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

### Nextcloud Access

- **URL**: http://192.168.0.100/nextcloud/
- **Database**: MariaDB (credentials stored in `secret/mariadb`)

## Deploying Changes

Changes to the `kubernetes/` directory are automatically synchronized by ArgoCD.

1. Make changes to YAML files in `kubernetes/`
2. Commit and push to GitHub
3. ArgoCD will automatically sync within seconds

## Manual Commands

### Kubernetes

```bash
# Apply changes manually (if needed)
kubectl apply -f kubernetes/

# Validate before applying
kubectl apply -f kubernetes/ --dry-run=client

# Check pods
kubectl get pods -n <namespace>
```

### ArgoCD CLI

```bash
# Install ArgoCD CLI
brew install argocd

# Login
argocd login http://192.168.0.100:8080/argocd

# Check sync status
argocd app list
```

## Secrets

- MariaDB credentials: stored in `secret/mariadb` namespace `nextcloud`
- Never commit secrets to git
- Use SealedSecrets or external-secrets for production

## Development

```bash
# Clone the repo
git clone https://github.com/lucasdiegorr/homelab.git

# Test Kubernetes manifests
kubectl kustomize kubernetes/apps/nextcloud/

# View ArgoCD applications
kubectl get applications -n argocd
```