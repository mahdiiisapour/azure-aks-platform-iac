# Azure AKS Platform IaC

Portfolio-grade Azure AKS platform built step by step for learning and demonstrating senior Kubernetes platform architecture on Azure.

## Goal

Build a secure, GitOps-managed AKS platform for internal engineering teams, provisioned with Terraform and designed around Microsoft Entra identity, Azure networking, workload identity, Azure-native observability, policy-driven controls, and repeatable day-2 operations.

## Initial Scope

- One Azure subscription
- One non-production environment: `dev`
- Azure region: `westeurope`
- AKS Standard
- Terraform-managed Azure infrastructure
- GitHub Actions with OIDC federation
- Argo CD-managed Kubernetes resources
- Azure Container Registry
- Azure Key Vault
- Microsoft Entra ID and Azure RBAC
- Azure Workload Identity
- Azure Monitor, Managed Prometheus, and Managed Grafana
- One sample workload proving Key Vault access without static credentials

## Non-Goals

- Multi-region disaster recovery
- Full Azure landing zone
- Hub-and-spoke networking
- Azure Firewall
- Private AKS API endpoint
- Multiple subscriptions or environments
- Production workloads or real data
- Premature reusable Terraform modules

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

Step 0/1 foundation only. No Azure resources have been created.

