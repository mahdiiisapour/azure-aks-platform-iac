# AKS Cluster

This layer creates the first AKS cluster for the North Europe `dev` environment.

It is intentionally small because the subscription is still on Azure Free Trial. The cluster is useful for testing the platform wiring, but it should not be treated as resilient.

## What This Layer Creates

- AKS cluster `aks-platform-dev-neu`
- User-assigned managed identity for the AKS control plane
- User-assigned managed identity for the kubelet
- Subnet-scoped Azure RBAC assignments for AKS networking
- Managed Identity Operator assignment over the kubelet identity
- Azure Kubernetes Service RBAC Cluster Admin assignment for the current human principal
- One temporary system node pool

It does not create ACR, Key Vault, Argo CD, observability, ingress, NAT Gateway, Azure Firewall, private endpoints, workload identities, or workloads.

## Current Cluster Shape

North Europe currently has only 4 regional vCPUs available in this Azure Free Trial subscription. For that reason, this layer creates exactly one system node.

The node size is `Standard_EC2as_v5`, which gives 2 vCPUs and 16 GB RAM. It is a non-B-series SKU that is available to this subscription in North Europe.

One system node is not resilient. A production AKS cluster should have at least two system nodes, and three is usually a better starting point. Availability zones should also be considered once the design moves beyond this small lab shape.

The user node pool is deferred because the current quota is too small for a separate workload pool. The user subnet still exists and is ready for that later phase.

Node pool upgrade surge is set to `1`. During an upgrade, AKS may briefly need one extra `Standard_EC2as_v5` node. That can use the full 4-vCPU regional quota, so upgrades have very little headroom.

## Kubernetes Version Strategy

The cluster does not pin `kubernetes_version`. Azure will select the current supported default version for North Europe.

This avoids leaving an old patch version in the repo. A stricter environment would pin versions and upgrade them on purpose.

## Identity And Access

The cluster uses two user-assigned managed identities:

- Control plane: `id-aks-control-plane-dev-neu`
- Kubelet: `id-aks-kubelet-dev-neu`

The control-plane identity gets `Network Contributor` only on the system and user node subnets. It also gets `Managed Identity Operator` only over the kubelet identity.

Local AKS accounts are disabled. Human administration uses Microsoft Entra authentication with Azure RBAC. The current signed-in principal receives `Azure Kubernetes Service RBAC Cluster Admin` scoped to the AKS cluster resource.

Do not use `az aks get-credentials --admin`.

## Network Model

The intended network model is:

- Azure CNI Overlay
- Cilium data plane
- Cilium network policy
- Pod CIDR: `10.244.0.0/16`
- Service CIDR: `10.245.0.0/16`
- DNS service IP: `10.245.0.10`
- Outbound type: `loadBalancer`

Pods use the overlay Pod CIDR rather than consuming VNet IPs. Nodes use the existing system subnet from `infra/20-network`.

## Backend Configuration

Create local backend config:

```bash
cp backend.hcl.example backend.local.hcl
```

Initialise:

```bash
terraform init -backend-config=backend.local.hcl
```

## Local Network Inputs

This layer does not use `terraform_remote_state`. For this small single-environment setup, the required network values are copied into an ignored local tfvars file.

Read the network outputs:

```bash
terraform -chdir=../20-network output -json
```

Create `network.auto.tfvars` with:

```hcl
vnet_address_space = ["10.50.0.0/16"]
system_subnet_id   = "<subnet_ids.aks_system>"
user_subnet_id     = "<subnet_ids.aks_user>"
```

## Safe Planning

```bash
ARM_RESOURCE_PROVIDER_REGISTRATIONS=none terraform plan -out=tfplan
```

Review the plan before applying it. Apply remains a manual step.

## Diagrams

Identity flow:

```text
Terraform caller
  │
  ├─ reads current Entra principal
  │
  ├─ creates control-plane user-assigned identity
  │     └─ Azure RBAC: Network Contributor on system/user subnets
  │     └─ Azure RBAC: Managed Identity Operator on kubelet identity
  │
  ├─ creates kubelet user-assigned identity
  │
  └─ creates AKS using those identities
        └─ current Entra principal receives AKS RBAC Cluster Admin on cluster
```

Terraform dependency order:

```text
Network layer outputs copied to local tfvars
        │
        ▼
Control-plane and kubelet identities
        │
        ▼
Subnet Network Contributor assignments
        │
        ▼
Managed Identity Operator assignment
        │
        ▼
AKS cluster with one temporary system node
        │
        ▼
Current principal AKS RBAC Cluster Admin assignment
```
