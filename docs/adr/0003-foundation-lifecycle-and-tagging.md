# ADR 0003: Bootstrap-Owned Foundation Lifecycle and Tagging

## Status

Accepted

## Date

2026-07-02

## Context

The platform is split into Terraform layers with different lifecycles. Some resources must remain stable so that Terraform state and shared platform metadata are not destroyed during routine lab teardown.

The development platform resource group also needs clear naming and metadata so later layers can target it consistently.

## Decision

`infra/00-bootstrap` is the persistent bootstrap layer. It owns:

- Terraform state storage
- The persistent development platform resource group `rg-aks-platform-dev-neu`
- Shared project tags needed by those resources

`infra/10-foundation` has been removed to simplify the layer model.

The disposable layers are:

- `infra/20-network`
- `infra/30-aks`
- `infra/40-observability`
- `infra/50-security`

The development resource group remains when AKS is destroyed. AKS, networking, observability, and security resources can be removed and recreated inside the same resource group without deleting the organisational boundary.

Separating bootstrap and foundation would be more common in a larger organisation, especially with multiple subscriptions, environments, teams, or lifecycle owners. This repo keeps those persistent concerns together in `00-bootstrap` because the current platform has only one persistent resource group.

Use this naming convention for regional Azure resources:

```text
<resource-type>-<workload>-<environment>-<region>
```

For example:

```text
rg-aks-platform-dev-neu
```

Global-name resources such as Storage Accounts and Azure Container Registries need random suffixes because their names must be globally unique across Azure, not just unique inside a subscription or resource group.

Owner, cost, lifecycle, and classification metadata belong in tags rather than names.

## Rationale

Keeping bootstrap-owned foundation resources persistent avoids accidental loss of Terraform state storage and the platform resource group. The daily destroy workflow should target only resources that are expected to be recreated frequently.

Names should identify the resource type, workload, environment, and region. They should stay short, predictable, and stable.

Tags are better than names for metadata that may change or that is used for reporting:

- `owner`
- `cost-owner`
- `lifecycle`
- `component`
- `data-classification`

Changing tags is safer than renaming resources, and Azure cost and inventory tools can filter by tags directly.

## Alternatives Considered

### Destroy the development resource group every day

This would keep teardown simple, but it would also remove the stable container that later layers target. It increases the chance of accidental lifecycle coupling between persistent state and disposable workloads.

### Keep `10-foundation` as a separate persistent layer

This would be a conventional enterprise-style separation. It is not needed for the current scope because the only foundation resource is the persistent dev resource group.

### Encode owner and cost metadata in names

This makes names harder to read and more likely to require replacement when ownership changes.

### Use tags as an access-control boundary

Tags are useful metadata for reporting, automation, and policy evaluation, but they are not a security or access-control boundary. Access must be enforced with Azure RBAC, policy, network controls, and identity design.

## Consequences

The destroy workflow must explicitly exclude `00-bootstrap`.

Later layers should consume or consistently target the persistent dev resource group rather than creating their own top-level resource groups unless a new ADR changes the lifecycle model.
