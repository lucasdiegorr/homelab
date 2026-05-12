# AGENTS.md

Repository for k3s homelab managed via GitOps (ArgoCD).

## Important: Branch Protection

**The `master` branch is protected against direct commits.**
All changes must be submitted via Pull Request (PR).

Before making changes:
1. Create a feature branch from `master`
2. Make your changes and commit to the feature branch
3. Open a PR for review
4. After PR is merged, ArgoCD will automatically sync the changes

## Structure

- `kubernetes/` - K8s manifests organized by app/namespace
  - `system/` - System components (ArgoCD, etc.)
  - `apps/` - User applications (Nextcloud, etc.)
- `terraform/` - Infrastructure (VM, networking, storage)
- `ansible/` - Host-level configuration

## Key Commands

### Kubernetes

```bash
# Validate YAML before applying
kubectl apply -f kubernetes/ --dry-run=client

# Apply changes
kubectl apply -f kubernetes/

# Check resources
kubectl get all -n <namespace>
kubectl describe ingress -n <namespace>
```

### ArgoCD

```bash
# Check application sync status
kubectl get applications -n argocd

# View application details
kubectl describe application <app-name> -n argocd

# Force sync (via UI or CLI)
argocd app sync <app-name>
```

### Terraform

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Ansible

```bash
ansible-playbook -i inventory.ini playbook.yml
```

## Tips

- Use `kubectl --dry-run=client` to validate YAML before applying
- For ArgoCD: manifests must be in a git repo ArgoCD watches
- Keep secrets out of git (use SealedSecrets or manage manually)
- When updating secrets, delete the resource first before recreating to avoid ArgoCD overwriting
- Use Traefik IngressRoute for subpath routing (e.g., `/nextcloud`)
- **Always create a PR instead of pushing directly to master**
- **Keep the README.md updated** with current services and important information - this is the main entry point for the project

## Workflow (via PR)

```bash
# 1. Create feature branch
git checkout -b feature/my-new-app

# 2. Make changes and commit
git add .
git commit -m "Add new application"

# 3. Push branch
git push -u origin feature/my-new-app

# 4. Create PR via GitHub CLI or web UI
gh pr create --title "Add new application" --body "Description"
```

After the PR is merged, ArgoCD will automatically sync the changes to the cluster.

## Application Pattern

Each application should have its own directory under `kubernetes/apps/<app-name>/`:

```
kubernetes/apps/nextcloud/
├── namespace.yaml
├── kustomization.yaml
├── deployment.yaml
├── service.yaml
├── ingressroute.yaml
├── pvc.yaml
└── middleware.yaml (if needed)
```

The root `kubernetes/apps/kustomization.yaml` references all applications, and ArgoCD automatically syncs them.