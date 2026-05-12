# Homelab

A personal infrastructure-as-code project for managing a self-hosted cloud environment using Kubernetes (k3s) and GitOps.

## Overview

This repository contains the configuration and manifests to deploy and manage various self-hosted services in a home lab environment. The entire infrastructure is managed through GitOps, ensuring version-controlled, reproducible deployments.

## Features

- **GitOps-based Deployment**: All changes are declarative and synchronized automatically via ArgoCD
- **Self-hosted Services**: Cloud storage, workflow automation, and more
- **Container Orchestration**: Powered by k3s lightweight Kubernetes
- **Traefik Integration**: Reverse proxy with automatic routing for services
- **Persistent Storage**: Volume management for data persistence
- **Database Support**: MariaDB for relational data storage

## Architecture

```
┌─────────────────────────────────────┐
│           k3s Cluster              │
├─────────────────────────────────────┤
│  ArgoCD   │  Traefik  │  Services  │
│  (GitOps) │ (Ingress) │ (User Apps)│
└─────────────────────────────────────┘
```

### Directory Structure

```
kubernetes/     # Kubernetes manifests (GitOps)
├── system/     # System components (ArgoCD, etc.)
└── apps/       # User applications
terraform/      # Infrastructure definitions
ansible/        # Host configuration
```

## Services

| Service   | Description              |
|-----------|--------------------------|
| ArgoCD    | GitOps continuous delivery |
| Nextcloud | Self-hosted cloud storage  |
| N8N       | Workflow automation        |

## Getting Started

### Prerequisites

- k3s cluster running
- kubectl configured
- Git repository with this codebase

### Accessing Services

Services are accessible through Traefik at the configured endpoints. Access credentials are stored in Kubernetes secrets and should not be committed to git.

### Making Changes

1. Create a feature branch from `master`
2. Modify the desired Kubernetes manifests
3. Open a Pull Request for review
4. After merging, ArgoCD automatically syncs the changes

## Security

- **Never commit secrets** to this repository
- Use Kubernetes secrets or SealedSecrets for sensitive data
- Review all changes before merging

## License

MIT