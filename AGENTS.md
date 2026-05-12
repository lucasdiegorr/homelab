# AGENTS.md

Repository for k3s homelab managed via GitOps (ArgoCD).

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