# ADR 0002: Identity-First Access Model

## Status

Accepted

## Date

2026-06-25

## Context

AKS platforms need access paths for humans, automation, and workloads. Those access paths should be auditable, scoped, and based on identity rather than long-lived shared credentials.

The project should teach modern Azure access patterns from the beginning.

## Decision

Use an identity-first access model:

- Humans use Microsoft Entra ID plus Azure RBAC for AKS access.
- GitHub Actions uses OIDC federation, not client secrets.
- AKS workloads use Workload Identity and dedicated user-assigned managed identities.
- Key Vault access is least-privilege and scoped per workload boundary.
- AKS cluster and kubelet identities must not be reused by applications.

## Rationale

Entra ID and Azure RBAC provide individual accountability for human access. OIDC federation lets GitHub Actions authenticate to Azure without storing a long-lived Azure client secret. Workload Identity lets pods access Azure resources without cloud credentials in Kubernetes Secrets.

Dedicated user-assigned managed identities make workload permissions easier to review, rotate, and audit. Keeping cluster, kubelet, platform, and application identities separate reduces accidental privilege sharing.

## Alternatives Considered

### Static service-principal client secrets

Client secrets are familiar and widely supported, but they create rotation work and can be copied, leaked, or stored in the wrong place.

They are not chosen for GitHub Actions because OIDC federation provides short-lived token exchange without a stored Azure secret.

### Shared admin kubeconfigs

Shared admin kubeconfigs are convenient during early experiments, but they make access hard to attribute to an individual person and can bypass intended RBAC controls.

They are not chosen as the normal access model. Emergency access should be deliberately documented later if needed.

### Kubernetes Secrets containing cloud credentials

Kubernetes Secrets can hold application configuration, but placing Azure client secrets in them creates a high-value secret inside the cluster.

They are not chosen for Azure resource access. Workload Identity is the preferred pattern for pods that need Azure APIs.

### One broad managed identity for all workloads

A single broad identity is simple to wire up, but it couples unrelated workloads to the same permissions and audit trail.

It is not chosen because workload boundaries should have separate least-privilege identities.

## Consequences

The platform will need more identity objects and clearer permission design than a secret-based setup.

That added design work improves auditability and reduces credential exposure. It also makes later incident response and permission reviews more realistic.
