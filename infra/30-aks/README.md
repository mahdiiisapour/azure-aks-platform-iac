# AKS Cluster Layer

This disposable layer creates the temporary AKS cluster foundation for the North Europe `dev` environment.

It creates:

- AKS cluster `aks-platform-dev-neu`
- Control-plane user-assigned managed identity
- Kubelet user-assigned managed identity
- Subnet-scoped Azure RBAC assignments for AKS networking
- Managed Identity Operator assignment over the kubelet identity
- Azure Kubernetes Service RBAC Cluster Admin assignment for the current human principal
- One temporary system node pool

It does not create ACR, Key Vault, Argo CD, observability resources, ingress, NAT Gateway, Azure Firewall, private endpoints, application identities, or workloads.

## Temporary Free Trial Shape

The Azure Free Trial quota in North Europe currently allows only 4 total regional vCPUs. This phase therefore creates exactly one system node using `Standard_EC2as_v5`, a 2-vCPU, 16-GB non-B-series SKU that is available to this subscription.

This is a non-resilient lab configuration. Production AKS should use at least two system nodes, preferably three or more, and should normally use availability zones where available.

The user node pool is intentionally deferred because the current quota is too small for a resilient system pool plus user capacity. The existing user subnet remains reserved for a later phase.

Node pool upgrade surge is set to `1`. With the selected 2-vCPU node size, an upgrade can temporarily require the full 4-vCPU Free Trial regional quota. This leaves no spare quota headroom and remains a lab-only compromise.

## Kubernetes Version Strategy

The cluster does not pin `kubernetes_version`. Azure will select the current supported default version for North Europe.

This avoids hard-coding an old patch version. A future production design may pin and deliberately upgrade versions through a controlled process.

## Identity And Access

The cluster uses pre-created user-assigned managed identities:

- Control plane: `id-aks-control-plane-dev-neu`
- Kubelet: `id-aks-kubelet-dev-neu`

The control-plane identity receives `Network Contributor` only on the system and user node subnets. It also receives `Managed Identity Operator` only over the kubelet identity.

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

This layer intentionally does not use `terraform_remote_state`. Create an ignored local tfvars file from the network outputs:

```bash
terraform -chdir=../20-network output -json
```

Then create `network.auto.tfvars` with:

```hcl
vnet_address_space = ["10.50.0.0/16"]
system_subnet_id   = "<subnet_ids.aks_system>"
user_subnet_id     = "<subnet_ids.aks_user>"
```

## Safe Planning

```bash
ARM_RESOURCE_PROVIDER_REGISTRATIONS=none terraform plan -out=tfplan
```

Do not run `terraform apply`; that command is reserved for the manual approval step.

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
AKS cluster with one system node
        │
        ▼
Current principal AKS RBAC Cluster Admin assignment
```
