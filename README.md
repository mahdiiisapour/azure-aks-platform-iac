# Azure AKS Platform

Terraform for a small Azure AKS platform in a single `dev` environment.

## Goal

Build a secure AKS platform that can later be managed with GitOps. The current focus is the Azure side: state storage, networking, cluster identity, RBAC, and a small AKS cluster that fits inside the Azure Free Trial limits.

## Initial Scope

- One Azure subscription
- One `dev` environment
- North Europe (`northeurope`, `neu`)
- AKS Free tier for now because this subscription is cost and quota constrained
- Terraform for Azure infrastructure
- GitHub Actions with OIDC federation
- Argo CD for Kubernetes GitOps
- Azure Container Registry
- Azure Key Vault
- Entra ID, Azure RBAC, and Workload Identity
- Azure Monitor, Managed Prometheus, and Managed Grafana
- Sample workload that accesses Key Vault without static credentials

## Non-Goals

- Multi-region disaster recovery
- Private AKS API endpoint
- Hub-spoke networking
- Azure Firewall
- Full landing zone
- Production workloads or data
- Premature reusable Terraform modules

## Ownership Model

- Terraform owns Azure resources.
- Argo CD owns Kubernetes resources.

## Repository Layout

```text
infra/
  00-bootstrap/       Terraform state storage and persistent dev resource group
  20-network/         VNet and subnets
  30-aks/             AKS cluster, identities, and cluster RBAC
  40-observability/   Azure Monitor, Managed Prometheus, and Grafana
  50-security/        Key Vault, workload identity, and policies
docs/
  architecture/       Architecture notes and diagrams
  adr/                Architecture decision records
  runbooks/           Operational procedures
scripts/              Local helper scripts
.github/
  workflows/          CI/CD automation
```

## Commit Safety

Do not commit:

- Terraform state files
- Terraform variable files containing real values
- Terraform plan files
- Azure credentials
- Client secrets
- Tokens
- Kubeconfigs
- Private keys or certificates
- Real workload secrets

Prefer Microsoft Entra identity, OIDC federation, managed identity, and Azure Workload Identity over static credentials.

## Current Status

Phase 4A — AKS cluster foundation.

`infra/00-bootstrap` owns Terraform state storage and the persistent `dev` platform resource group. `infra/20-network` owns the disposable VNet and subnets. `infra/30-aks` now owns a temporary one-node AKS cluster using `Standard_EC2as_v5`.

The cluster is deliberately small. It is enough to test the platform wiring, but it is not a resilient production shape.
