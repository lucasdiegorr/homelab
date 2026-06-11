# AGENTS.md

Repository for k3s homelab managed via GitOps (ArgoCD).

## Important: Branch Protection

**The `master` branch is protected against direct commits.**
All changes must be submitted via Pull Request (PR).

Before making changes:
1. **Always pull latest master** before creating a feature branch:
   ```bash
   git checkout master && git pull origin master
   ```
2. Create a feature branch from `master`:
   ```bash
   git checkout -b feature/my-change
   ```
3. Make your changes and commit to the feature branch
4. Open a PR for review
5. After PR is merged, ArgoCD will automatically sync the changes
6. Delete the feature branch locally to keep the repo clean:
   ```bash
   git checkout master && git pull origin master
   git branch -d feature/my-change
   ```

## Structure

- `kubernetes/` - K8s manifests organized by app/namespace
  - `system/` - System components (ArgoCD, etc.)
  - `apps/` - User applications (Nextcloud, N8N, Jellyfin, Traefik)
- `terraform/` - Infrastructure (Cloudflare tunnel config, DNS records)
- `ansible/` - Host-level configuration

## Key Commands

### Kubernetes

```bash
# Validate YAML before applying
kubectl apply -f kubernetes/ --dry-run=client

# Check resources
kubectl get all -n <namespace>
kubectl describe ingressroute -n <namespace>
kubectl get middleware -A

# Check Traefik routers (port-forward required)
kubectl port-forward -n kube-system svc/traefik 9000:9000 &
curl -s http://localhost:9000/api/http/routers
```

### ArgoCD

```bash
# Check application sync status
kubectl get applications -n argocd

# View application details
kubectl describe application <app-name> -n argocd

# Force sync (via CLI)
argocd app sync <app-name>
```

### Terraform

```bash
# Initialize (first time or after provider changes)
terraform init

# Preview and apply
terraform plan -out=tfplan
terraform apply tfplan

# Quick apply (after initial plan)
terraform apply -auto-approve
```

### Cloudflare API Token

```bash
# Verify token validity
curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/<ACCOUNT_ID>/tokens/verify" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
```

Token is stored in `terraform/terraform.tfvars` (gitignored) and `~/.bashrc` for interactive shells.
Note: `~/.bashrc` returns early in non-interactive shells, so Terraform uses `terraform.tfvars`.

### Ansible

```bash
# Full provisioning (secrets via --extra-vars)
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml \
  -e duckdns_token=token \
  -e cloudflare_account_id=id

# Selective roles
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml --tags cockpit

# Secrets file (gitignored)
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml \
  -e @ansible/secrets.yml
```

## Architecture: Path-Based Access

All apps are accessed at `lucasrocha.dpdns.org/<app>` via Cloudflare Tunnel (WAN) or `192.168.0.100/<app>` (LAN).

### WAN (via Cloudflare Tunnel)

```
Browser → Cloudflare Tunnel → Traefik web:80 → IngressRoute (Host: lucasrocha.dpdns.org + PathPrefix)
```

- Tunnel has a single ingress rule: `lucasrocha.dpdns.org → http://192.168.0.100:80`
- IngressRoute matches `Host(lucasrocha.dpdns.org) && PathPrefix(/<app>)`
- Middlewares: `strip-<app>` (removes path prefix) + `https-proto` (sets X-Forwarded-Proto: https)
- Terraform manages tunnel config + DNS CNAME (via `cloudflare_zero_trust_tunnel_cloudflared_config`)

### LAN (direct)

```
Browser → Traefik web:80 → IngressRoute (Host: 192.168.0.100 + PathPrefix)
```

- IngressRoute matches `Host(192.168.0.100) && PathPrefix(/<app>)`
- Middleware: `strip-<app>` only (no https-proto, no proto override)

### Traefik

- Single entrypoint: `web` (port 80)
- Differentiates WAN from LAN by `Host` header
- Runs as LoadBalancer at `192.168.0.100` in `kube-system` namespace
- Extra entrypoints (`web-nextcloud`, `web-n8n`, `web-jellyfin`) were removed in PR #20

## Application Pattern

Each application has its own directory under `kubernetes/apps/<app-name>/`:

```
kubernetes/apps/nextcloud/
├── namespace.yaml
├── kustomization.yaml
├── deployment.yaml
├── service.yaml
├── ingressroute-port.yaml      # WAN IngressRoute (Host: lucasrocha.dpdns.org)
├── ingressroute-lan.yaml       # LAN IngressRoute (Host: 192.168.0.100)
├── middleware-nextcloud.yaml    # strip-<app> + https-proto middlewares
├── pvc.yaml
└── ...
```

### IngressRoute WAN Template

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: <app>
  namespace: <namespace>
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`lucasrocha.dpdns.org`) && PathPrefix(`/<app>`)
      kind: Rule
      middlewares:
        - name: strip-<app>
        - name: https-proto
      services:
        - name: <app>
          port: 80
```

### IngressRoute LAN Template

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: <app>-lan
  namespace: <namespace>
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`192.168.0.100`) && PathPrefix(`/<app>`)
      kind: Rule
      middlewares:
        - name: strip-<app>
      services:
        - name: <app>
          port: 80
```

### Middleware Template

```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: strip-<app>
  namespace: <namespace>
spec:
  stripPrefix:
    prefixes:
      - /<app>
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: https-proto
  namespace: <namespace>
spec:
  headers:
    customRequestHeaders:
      X-Forwarded-Proto: "https"
```

## App-Specific Configuration

### Nextcloud

- `overwritewebroot=/nextcloud` set via env var in deployment
- `OVERWRITEPROTOCOL` removed — replaced by `https-proto` middleware on WAN routes
- `trusted_proxies` configured for `192.168.0.100` and `10.42.0.0/16`

### N8N

- `WEBHOOK_URL=https://lucasrocha.dpdns.org/n8n/`
- `N8N_EDITOR_BASE_URL=https://lucasrocha.dpdns.org/n8n/`

### Jellyfin

- `JELLYFIN_PublishedServerUrl=https://lucasrocha.dpdns.org/jellyfin`

## Terraform-Managed Cloudflare Resources

The following are managed via Terraform (not the Cloudflare dashboard):

| Resource | Purpose |
|---|---|
| `cloudflare_zero_trust_tunnel_cloudflared_config` | Tunnel ingress rules (single rule → port 80) |
| `cloudflare_dns_record` | CNAME apex → tunnel |

### Token Permissions

The Terraform API token needs **two resource scopes**:

1. **Account** → All resources: Cloudflare Tunnel:Write, Account Settings:Read, Account DNS Settings:Read
2. **Zone** (lucasrocha.dpdns.org) → All resources: DNS:Write, Zone:Read, Zone DNS Settings:Write, DNS:Read

## Tips

- Use `kubectl --dry-run=client` to validate YAML before applying
- For ArgoCD: manifests must be in a git repo ArgoCD watches
- Keep secrets out of git (use SealedSecrets or manage manually)
- When updating secrets, delete the resource first before recreating to avoid ArgoCD overwriting
- **Always create a PR instead of pushing directly to master**
- **Always pull latest master before creating a feature branch** to avoid stale base
- **Keep the README.md updated** with current services and important information
- **When adding a new app under `kubernetes/apps/`, add it to `kubernetes/apps/kustomization.yaml`** — otherwise ArgoCD won't deploy it
- **When adding a new app, also update `README.md`** (directory structure + services table)
- **`nslookup` bypasses the hosts file** on Windows — use `ping` to test hosts file resolution
- **`~/.bashrc` has a non-interactive shell guard** (`case $- in *i*) ;; *) return;; esac`) — env vars set after the guard won't be available in non-interactive shells like CI or the bash tool
- **Browser might auto-redirect to HTTPS** for `lucasrocha.dpdns.org` due to HSTS — use incognito mode or `http://192.168.0.100/<app>` for LAN testing
