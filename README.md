# Azure AKS Platform Reference Architecture

Secure, GitOps-managed Azure AKS platform for internal engineering teams.

## Goal

Build a secure, GitOps-managed AKS platform for internal engineering teams, provisioned with Terraform and designed around Entra ID, Azure RBAC, Workload Identity, Azure networking, Azure-native observability, policy-driven controls, and repeatable day-2 operations.

## Initial Scope

- One Azure subscription
- One `dev` environment
- `westeurope`
- AKS Standard
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
  00-bootstrap/       Terraform state storage and CI/CD identity
  10-foundation/      Resource groups, names, tags, budgets, shared conventions
  20-network/         VNet, subnets, and network controls
  30-aks/             AKS, node pools, and cluster configuration
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

Phase 0 — Architecture and repository foundation.

No Azure resources have been created.
