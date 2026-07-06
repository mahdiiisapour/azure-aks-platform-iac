# ADR 0004: AKS Network Baseline

## Status

Accepted

## Date

2026-07-06

## Context

The platform needs a simple Azure network baseline before AKS is introduced. This phase should reserve enough address space for a future AKS cluster without adding routing, egress, private endpoint, or cluster complexity too early.

## Decision

Create one VNet in North Europe:

```text
vnet-aks-platform-dev-neu  10.50.0.0/16
```

Create four subnets:

```text
snet-aks-system-dev-neu        10.50.0.0/24
snet-aks-user-dev-neu          10.50.1.0/24
snet-private-endpoints-dev-neu 10.50.2.0/24
snet-reserved-dev-neu          10.50.3.0/24
```

Reserve these future AKS Kubernetes ranges:

```text
Pod CIDR        10.244.0.0/16
Service CIDR    10.245.0.0/16
DNS service IP  10.245.0.10
```

The intended future AKS network model is:

- Azure CNI Overlay
- Cilium data plane
- Separate system and user node pools using the two active AKS subnets
- Initial outbound type: `loadBalancer`

## Rationale

Azure CNI Overlay lets nodes use VNet IPs while pods use an overlay address range. This avoids consuming VNet IP addresses for every pod and keeps subnet planning easier than classic Azure CNI Pod Subnet mode.

Cilium is the intended data plane because it aligns with modern AKS networking capabilities and gives a strong future path for Kubernetes network policy and observability.

The initial future egress choice is `loadBalancer` because it is the simplest AKS-managed outbound model. It avoids NAT Gateway and Azure Firewall costs while the platform is still establishing its baseline.

Separate system and user subnets keep future node pool boundaries clear. Reserved private endpoint and expansion subnets reduce the chance that the VNet must be reshaped later.

## Alternatives Considered

### Azure CNI Pod Subnet

Pod Subnet mode gives pods IPs from Azure subnet space. It can be a good fit when direct pod routability from the VNet is required.

It is postponed because it consumes VNet IPs more aggressively and adds subnet sizing pressure before workload requirements are known.

### NAT Gateway

NAT Gateway gives predictable outbound IPs and higher scale for egress.

It is postponed because it adds cost and is not needed before AKS and outbound requirements are defined.

### Azure Firewall

Azure Firewall gives centralised egress control and inspection.

It is postponed because it adds significant cost and operational complexity. It is more appropriate once workload egress policy requirements are clear.

### Private AKS Cluster

A private AKS API endpoint reduces public control-plane exposure.

It is postponed because it requires additional DNS and connectivity design. The initial platform remains simpler while identity, GitOps, and network basics are established.

## Consequences

This phase creates only the base network shape. It does not enforce subnet-level security, route outbound traffic through a dedicated appliance, or create private connectivity.

Those controls can be added later through explicit architecture decisions.

