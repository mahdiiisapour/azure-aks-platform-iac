# Bootstrap Terraform State Storage

This layer creates the Azure Storage resources that will later hold Terraform remote state.

It must be applied first while Terraform still uses local state. There is no `backend "azurerm"` block in this layer by design, because the backend storage account and container do not exist until after the first successful apply.

## What This Layer Creates

- A dedicated bootstrap resource group in North Europe
- A StorageV2 storage account with a random suffix for global uniqueness
- A private `tfstate` blob container
- A role assignment granting the current Azure principal `Storage Blob Data Contributor` on the state container

The wider AKS platform remains scoped to West Europe. Bootstrap state storage is placed in North Europe because storage account creation in West Europe was rejected for this subscription with Azure's `locationineligible` response.

## Why A Separate Resource Group

Terraform state is platform-critical. Keeping it in its own bootstrap resource group separates state storage from later AKS platform resources and makes ownership, review, and future lifecycle decisions clearer.

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

## Future State Migration Goal

After this layer has been applied successfully, a later change will migrate Terraform state to Azure Blob remote state authenticated through Microsoft Entra ID.

That future step will add an `azurerm` backend block and migrate state deliberately. It is intentionally not part of this first bootstrap implementation.

## Required Permissions

The signed-in Azure principal must be able to:

- Create resource groups and storage accounts in the target subscription
- Create blob containers through Azure Resource Manager
- Assign Azure RBAC roles at the container scope

The role assignment requires permissions such as `Owner` or `User Access Administrator` at the relevant scope.

## Safe Commands

```bash
terraform fmt -recursive
terraform init
terraform validate
```

Do not run `terraform apply` until the planned resources and required permissions have been reviewed.
