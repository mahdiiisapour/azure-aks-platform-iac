# ADR 0005: First AKS Cluster Shape

## Status

Accepted

## Date

2026-07-16

## Context

The repo now has persistent state storage, a persistent development resource group, and a disposable network baseline. The next step is a small AKS cluster that proves the identity and network wiring.

The subscription is an Azure Free Trial with a current North Europe quota of 4 total regional vCPUs. This constrains the first AKS cluster to a temporary one-node lab shape.

## Decision

Create AKS `aks-platform-dev-neu` in North Europe using:

- AKS Free tier
- Public API endpoint
- Local accounts disabled
- Microsoft Entra authentication
- Azure RBAC for Kubernetes authorisation
- OIDC issuer enabled
- Workload Identity enabled
- Azure CNI Overlay
- Cilium data plane and network policy
- A pre-created control-plane user-assigned managed identity
- A pre-created kubelet user-assigned managed identity
- One system node only, using `Standard_EC2as_v5`

The user node pool is deferred because of Free Trial quota limits.

## Rationale

AKS is configured directly rather than using AKS Automatic because the repo should show the platform decisions: identities, node pools, RBAC scopes, networking, and operational trade-offs.

The cluster uses the Free tier because this environment is cost-constrained. A production design should use the Standard tier, availability zones, and stronger operational controls.

The API endpoint remains public initially to avoid private DNS and private connectivity complexity before the cluster baseline is working. Local accounts are disabled so normal access flows through Microsoft Entra ID and Azure RBAC rather than admin kubeconfigs.

Control-plane and kubelet identities are separate so Azure permissions are scoped to the responsibility of each identity. The control-plane identity receives `Network Contributor` only on the system and user node subnets, and `Managed Identity Operator` only on the kubelet identity. These scopes avoid broad subscription or resource-group assignments.

OIDC issuer and Workload Identity are enabled now so later workloads can use federated identity without redesigning the cluster.

Azure CNI Overlay with Cilium is selected because pods do not consume VNet IPs, while the cluster still gets a modern data plane and network-policy path.

The system node pool has one node only because the Free Trial quota cannot support the preferred two or three system nodes. This is not resilient. Production should use at least two system nodes, and three is usually a better starting point.

The selected VM SKU is `Standard_EC2as_v5`, which has 2 vCPUs and 16 GB RAM. It is a non-B-series SKU available to this subscription in North Europe, has enough family quota, and fits the current 4-vCPU regional quota. It is a temporary lab compromise.

Upgrade surge is set to `1`. That is the AKS-supported setting for this node pool, but it means upgrades may temporarily consume the full 4-vCPU regional quota.

## Alternatives Considered

### AKS Automatic

AKS Automatic reduces the number of platform decisions. It is not chosen here because the repo should keep those decisions visible.

### AKS Standard tier

The Standard tier is more appropriate for production. It is deferred to control cost.

### Private API endpoint

A private API endpoint reduces public exposure, but it requires private DNS and connectivity design. It is deferred.

### NAT Gateway or Azure Firewall

Both provide stronger egress control than basic load balancer outbound. They are deferred because they add cost and operational complexity before workload requirements are known.

### User node pool in the first AKS phase

A user node pool is the right production direction, especially for separating platform and workload capacity. It is deferred because the current quota can only support the temporary system pool.

## Consequences

The first cluster is non-resilient. It is useful for validating identity, networking, Azure RBAC, OIDC, Workload Identity, and basic cluster operations, but it should not be treated as production-like.

Future production differences include:

- Three or more system nodes
- Availability zones
- Standard tier
- Private API endpoint
- Controlled egress
- Multiple workload-specific user node pools
- Larger quota and capacity planning
