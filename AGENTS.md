# AGENTS.md

Repository for k3s homelab managed via GitOps (ArgoCD/Flux).

## Structure

- `kubernetes/` - K8s manifests organized by app/namespace
- `terraform/` - Infrastructure (VM, networking, storage)
- `ansible/` - Host-level configuration

## Key Commands

- **K8s apply**: `kubectl apply -f kubernetes/` (or let GitOps handle it)
- **Terraform**: `terraform init && terraform plan -out=tfplan && terraform apply tfplan`
- **Ansible**: `ansible-playbook -i inventory.ini playbook.yml`

## Tips

- Use `kubectl --dry-run=client` to validate YAML before applying
- For ArgoCD: manifests must be in a git repo ArgoCD watches
- Keep secrets out of git (use SealedSecrets, external-secrets, or vault)