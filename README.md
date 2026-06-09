# Homelab

A personal infrastructure-as-code project for managing a self-hosted cloud environment using Kubernetes (k3s), GitOps (ArgoCD), and Cloudflare Tunnel.

## Overview

This repository contains the configuration and manifests to deploy and manage various self-hosted services in a home lab environment. The entire infrastructure is managed through GitOps, ensuring version-controlled, reproducible deployments.

All services are accessible via path-based routing on a single domain:

| Access | URL Pattern |
|---|---|
| **WAN** (via Cloudflare Tunnel) | `https://lucasrocha.dpdns.org/<app>` |
| **LAN** (direct) | `http://192.168.0.100/<app>` |

## Features

- **GitOps-based Deployment**: All changes are declarative and synchronized automatically via ArgoCD
- **Path-Based Access**: Single domain + path prefixes for all services, no subdomain management
- **Cloudflare Tunnel**: Secure WAN access without opening firewall ports
- **Infrastructure as Code**: Tunnel config and DNS records managed via Terraform
- **Container Orchestration**: Powered by k3s lightweight Kubernetes
- **Traefik Reverse Proxy**: Host-based differentiation between WAN and LAN traffic
- **Persistent Storage**: Volume management for data persistence
- **Database Support**: MariaDB for relational data storage

## Architecture

```
WAN (Internet)
     │
     ▼
Cloudflare Tunnel  ───→  Traefik (web:80)
                               │
                    ┌──────────┴──────────┐
                    │  Host Header Match  │
                    └──────┬──────┬───────┘
                           │      │
                     lucasrocha    192.168.0.100
                     .dpdns.org     (LAN direct)
                           │      │
                    ┌──────┘      └──────┐
                    ▼                    ▼
              + https-proto         no proto override
              middleware              
                    │                    │
                    └──────┬─────────────┘
                           ▼
                    ┌──────────┐
                    │ Traefik  │
                    │ Ingress  │
                    │ Routes   │
                    │ (strip   │
                    │  prefix) │
                    └────┬─────┘
                         ▼
              ┌──────────────────────┐
              │  Kubernetes Services│
              │  (Nextcloud, N8N,   │
              │   Jellyfin, ...)    │
              └──────────────────────┘
```

### Directory Structure

```
kubernetes/     # Kubernetes manifests (GitOps)
├── system/     # System components (ArgoCD, Traefik)
├── apps/       # User applications
│   ├── nextcloud/
│   ├── n8n/
│   └── jellyfin/
terraform/      # Infrastructure (Cloudflare tunnel + DNS)
ansible/        # Host configuration
```

## Services

| Service   | Description              | WAN URL                                        |
|-----------|--------------------------|-------------------------------------------------|
| ArgoCD    | GitOps continuous delivery | -                                               |
| Nextcloud | Self-hosted cloud storage  | `https://lucasrocha.dpdns.org/nextcloud`        |
| N8N       | Workflow automation        | `https://lucasrocha.dpdns.org/n8n`              |
| Jellyfin  | Media server               | `https://lucasrocha.dpdns.org/jellyfin`         |

## Getting Started

### Prerequisites

- k3s cluster running
- kubectl configured
- Terraform CLI (for infrastructure changes)
- Cloudflare API token with Tunnel:Write + DNS:Write permissions

### Accessing Services

**From WAN**: `https://lucasrocha.dpdns.org/<app>` — goes through Cloudflare Tunnel
**From LAN**: `http://192.168.0.100/<app>` — direct, no HTTPS

Access credentials are stored in Kubernetes secrets and should not be committed to git.

### Making Changes

1. Always pull latest master: `git checkout master && git pull origin master`
2. Create a feature branch: `git checkout -b feature/my-change`
3. Modify the desired manifests
4. Open a Pull Request for review
5. After merging, ArgoCD automatically syncs the changes

### Infrastructure Changes (Terraform)

```bash
cd terraform/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Terraform-Managed Resources

| Resource | Purpose |
|---|---|
| Tunnel config | Cloudflare Tunnel ingress rules |
| DNS record | CNAME apex → tunnel |

The Cloudflare API token must have account-level (Tunnel:Write) and zone-level (DNS:Write) permissions.

## Security

- **Never commit secrets** to this repository (`*.tfvars`, `*secret.yaml`, etc.)
- Use Kubernetes secrets or SealedSecrets for sensitive data
- Review all changes before merging
- Cloudflare Tunnel provides WAN access without exposing ports

## License

MIT
