# Foundation Layer

This layer owns the persistent development platform resource group only.

It creates `rg-aks-platform-dev-neu` in North Europe. Later layers create and destroy their resources inside this resource group, but this foundation layer remains outside the daily destroy workflow.

## Why This Layer Is Persistent

The platform resource group is metadata and organisation, not a runtime workload. Keeping it persistent gives disposable layers a stable target while allowing AKS, networking, observability, and security resources to be destroyed independently.

This layer has effectively no meaningful runtime cost because an empty Azure resource group is only a management container.

## Backend Configuration

This layer uses the Azure Blob remote state storage created by `infra/00-bootstrap`.

The committed `backend.tf` contains only a partial backend block. Local backend details belong in `backend.local.hcl`, which is ignored by Git.

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
key                  = "foundation/terraform.tfstate"
use_azuread_auth     = true
```

Initialise Terraform with the local backend config:

```bash
terraform init -backend-config=backend.local.hcl
```

## Safe Planning

Use Azure CLI login locally. The signed-in principal needs access to the remote state container and permission to create the platform resource group.

Run a safe plan without automatic Azure resource provider registration:

```bash
ARM_RESOURCE_PROVIDER_REGISTRATIONS=none terraform plan
```

Do not run `terraform apply` until the plan has been reviewed.

