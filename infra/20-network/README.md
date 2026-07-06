# Network Layer

This disposable layer creates the Azure network foundation for the future AKS cluster in North Europe.

It creates one virtual network and four subnets inside the persistent development resource group `rg-aks-platform-dev-neu`.

## What This Layer Creates

- Virtual network: `vnet-aks-platform-dev-neu`
- System node subnet: `snet-aks-system-dev-neu`
- User node subnet: `snet-aks-user-dev-neu`
- Reserved private endpoint subnet: `snet-private-endpoints-dev-neu`
- Reserved expansion subnet: `snet-reserved-dev-neu`

It does not create AKS, public IPs, load balancers, NAT Gateway, Azure Firewall, NSGs, route tables, private endpoints, private DNS zones, peering, or ingress.

## Addressing Model

The VNet address space is Azure network address space:

```text
10.50.0.0/16
```

The node subnets are carved from this range:

```text
10.50.0.0/24  system AKS nodes
10.50.1.0/24  user AKS nodes
10.50.2.0/24  reserved private endpoints
10.50.3.0/24  reserved future expansion
```

The future Kubernetes-only ranges are documented in Terraform locals and outputs, but are not applied to Azure resources in this phase:

```text
Pod CIDR        10.244.0.0/16
Service CIDR    10.245.0.0/16
DNS service IP  10.245.0.10
```

VNet and subnet CIDRs are used by Azure resources. Pod CIDR and Service CIDR are used by Kubernetes networking.

## Future AKS Direction

The intended future AKS model is Azure CNI Overlay with the Cilium data plane.

With Azure CNI Overlay, nodes use IPs from the VNet subnets, while pods use an overlay Pod CIDR. This avoids consuming one VNet IP per pod and keeps subnet sizing simpler for this environment.

The future AKS system node pool will use `snet-aks-system-dev-neu`. The future user node pool will use `snet-aks-user-dev-neu`.

## Why Separate System And User Subnets

Separate subnets give the platform a clean boundary between system and user node pools. This can help later with route tables, security rules, monitoring, and operational reasoning without forcing those controls into this phase.

## Why Reserve Private Endpoint And Expansion Subnets

Private endpoints are not created yet, but reserving a subnet now avoids reshaping the VNet later when services such as Key Vault, ACR, or monitoring components may need private connectivity.

The reserved expansion subnet gives the platform room for future experiments without changing the initial VNet layout.

## Why No Egress Or Security Appliances Yet

This phase intentionally avoids NSGs, route tables, NAT Gateway, Azure Firewall, private endpoints, and AKS.

Those choices affect cost, routing, operations, and security posture. They should be introduced only when the AKS and workload requirements make the trade-offs concrete.

## Lifecycle

This layer is disposable and is included in `scripts/destroy-lab.sh`.

Destroying this layer removes only the network resources managed here. The persistent bootstrap layer and development resource group remain protected.

## Backend Configuration

This layer uses the Azure Blob remote state storage created by `infra/00-bootstrap`.

Create the local backend config from the example:

```bash
cp backend.local.hcl.example backend.local.hcl
```

Read the storage account name from the bootstrap layer:

```bash
terraform -chdir=../00-bootstrap output -raw storage_account_name
```

Edit `backend.local.hcl` and set:

```hcl
resource_group_name  = "rg-aks-platform-bootstrap-neu"
storage_account_name = "<value-from-00-bootstrap-output>"
container_name       = "tfstate"
key                  = "network/terraform.tfstate"
use_azuread_auth     = true
```

Initialise Terraform with the local backend config:

```bash
terraform init -backend-config=backend.local.hcl
```

Run a safe plan without automatic Azure resource provider registration:

```bash
ARM_RESOURCE_PROVIDER_REGISTRATIONS=none terraform plan
```

