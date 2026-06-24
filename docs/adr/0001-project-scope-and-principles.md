# ADR 0001: Project Scope and Architecture Principles

## Status

Accepted

## Date

2026-06-24

## Context

This repository is a public, portfolio-grade Azure AKS platform project. The purpose is to learn and demonstrate Azure platform architecture for senior Kubernetes platform engineering roles.

The project should be realistic enough to show meaningful Azure decisions, but limited enough to stay reproducible, cost-conscious, and safe to destroy.

## Decision

Start with one Azure subscription, one `dev` environment, and the `westeurope` region.

The platform will use:

- Terraform for Azure infrastructure
- GitHub Actions with OIDC federation for CI/CD authentication
- Argo CD for Kubernetes GitOps
- AKS Standard
- Azure Container Registry
- Azure Key Vault
- Microsoft Entra ID and Azure RBAC
- Azure Workload Identity
- Azure Monitor, Managed Prometheus, and Managed Grafana

The project will follow these principles:

- Identity before secrets
- Terraform owns Azure resources
- Argo CD owns Kubernetes resources
- Start simple and introduce complexity only when its value is understood
- Prefer managed Azure services where they teach meaningful operational trade-offs
- Record major decisions as ADRs
- Keep the environment reproducible, cost-conscious, and safe to destroy
- Never present the learning environment as production-ready

## Alternatives Considered

### Full Azure landing zone first

This would better reflect a large enterprise setup with multiple subscriptions, management groups, hub-and-spoke networking, centralized policy, and shared connectivity.

It is not chosen initially because it adds too much platform surface area before the core AKS learning goals are visible.

### Production-style private platform first

This could include a private AKS API endpoint, Azure Firewall, private DNS, NAT Gateway, private endpoints, and strict egress controls.

It is not chosen initially because those services increase cost and operational complexity. They are valuable later once the baseline platform is understood.

### Reusable Terraform modules first

Reusable modules are useful when patterns have stabilized across environments or teams.

They are not chosen initially because this project is a learning platform. Clear, local Terraform is easier to reason about while architecture decisions are still being explored.

## Consequences

The first version will be simpler than a production enterprise platform, but easier to understand, review, destroy, and rebuild.

Some production-grade concerns are intentionally deferred:

- Multi-region disaster recovery
- Full landing zone alignment
- Hub-and-spoke networking
- Azure Firewall
- Private AKS API endpoint
- Multiple subscriptions
- Multiple environments

These can be introduced later through explicit ADRs.

