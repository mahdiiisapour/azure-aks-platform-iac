# Bootstrap Terraform State Storage

This layer creates the Azure Storage resources that hold Terraform remote state and owns the persistent development platform resource group.

It must be applied first while Terraform still uses local state. After the first successful apply, migrate the local state into the Azure Blob container using the procedure below.

## What This Layer Creates

- A dedicated bootstrap resource group in North Europe
- A StorageV2 storage account with a random suffix for global uniqueness
- A private `tfstate` blob container
- A role assignment granting the current Azure principal `Storage Blob Data Contributor` on the state container
- The persistent development platform resource group: `rg-aks-platform-dev-neu`

The wider AKS platform remains scoped to West Europe. Bootstrap state storage is placed in North Europe because storage account creation in West Europe was rejected for this subscription with Azure's `locationineligible` response.

## Why Bootstrap Owns The Dev Resource Group

Terraform state storage and the persistent dev resource group are both outside the daily destroy workflow. Keeping them together in `00-bootstrap` simplifies the repository while preserving the important lifecycle boundary: disposable platform resources can be destroyed without deleting state storage or the dev resource group.

Separating bootstrap and foundation would be more common in a larger enterprise platform, especially with multiple environments, subscriptions, or team ownership boundaries. This repository intentionally keeps that split simpler.

The dev resource group remains after daily cleanup. Later layers create network, AKS, observability, and security resources inside it.

## Why A Separate Bootstrap Resource Group

Terraform state is platform-critical. Keeping state storage in its own bootstrap resource group separates state storage from later AKS platform resources and makes ownership, review, and future lifecycle decisions clearer.

## Why Shared-Key Access Is Disabled

Shared-key access gives anyone with the account key broad access to the storage account. This layer disables shared-key access so Terraform state access uses Microsoft Entra ID and Azure RBAC instead.

The AzureRM provider is configured with `storage_use_azuread = true` so Blob and Queue API calls use Entra authentication rather than storage account keys.

## Why Versioning And Soft Delete Are Enabled

Terraform state is sensitive and operationally important. Blob versioning and soft delete provide a short recovery window if state is overwritten or deleted by mistake.

This layer enables:

- Blob versioning
- Blob soft delete for 7 days
- Container soft delete for 7 days

These controls are not a replacement for careful state handling, but they reduce the blast radius of accidental state changes.

## Why Public Network Access Is Temporarily Enabled

Public network access remains enabled initially because Terraform will run from a local workstation.

This avoids introducing private endpoints, DNS, VPN connectivity, NAT, or IP firewall rules before the platform network exists. Network restrictions should be added later as an explicit architecture decision.

## State Migration Procedure

This layer now declares a partial AzureRM backend in `backend.tf`. Backend settings that vary by local environment live in `backend.local.hcl`, which is intentionally ignored by Git.

From `infra/00-bootstrap`, obtain the storage account name from the existing local state:

```bash
terraform output -raw storage_account_name
```

Create the ignored backend config file from the committed example:

```bash
cp backend.local.hcl.example backend.local.hcl
```

Edit `backend.local.hcl` and set:

```hcl
resource_group_name  = "rg-aks-platform-bootstrap-neu"
storage_account_name = "<value-from-terraform-output>"
container_name       = "tfstate"
key                  = "bootstrap/terraform.tfstate"
use_azuread_auth     = true
```

Migrate local state into the Azure Blob backend:

```bash
terraform init -migrate-state -backend-config=backend.local.hcl
```

When Terraform prompts to copy the existing state to the new backend, confirm the migration.

Verify Terraform can read the migrated state:

```bash
terraform state list
```

Verify the state blob exists using Azure CLI with Entra authentication:

```bash
az storage blob show \
  --account-name "$(terraform output -raw storage_account_name)" \
  --container-name tfstate \
  --name bootstrap/terraform.tfstate \
  --auth-mode login
```

## Required Permissions

The signed-in Azure principal must be able to:

- Create resource groups and storage accounts in the target subscription
- Create blob containers through Azure Resource Manager
- Assign Azure RBAC roles at the container scope
- Read and write blobs in the `tfstate` container
- Import and manage the persistent dev platform resource group

The role assignment requires permissions such as `Owner` or `User Access Administrator` at the relevant scope.

Local Terraform backend access uses Azure CLI login. The principal used by `az login` needs `Storage Blob Data Contributor` on the state container.

## Safe Commands

```bash
terraform fmt -recursive
terraform init
terraform validate
```

Do not run `terraform apply` until the planned resources and required permissions have been reviewed.
