# Target Architecture

This document describes the intended shape of the Azure AKS platform for the initial `dev` environment.

## Overview

```text
Developer
  ├─ GitHub infrastructure repository
  └─ GitOps repository
        │
GitHub Actions
  └─ OIDC federation to Microsoft Entra ID
        │
Azure subscription
  ├─ Terraform state storage
  ├─ AKS platform resource group
  │   ├─ VNet and subnets
  │   ├─ AKS
  │   ├─ Azure Container Registry
  │   ├─ Azure Key Vault
  │   ├─ Azure Monitor / Log Analytics
  │   └─ Managed Prometheus / Grafana
  │
AKS
  ├─ Argo CD
  ├─ platform add-ons
  └─ sample workload
        └─ Workload Identity → Key Vault
```

The infrastructure repository contains Terraform for Azure resources. The GitOps repository contains Kubernetes desired state that Argo CD reconciles into the cluster.

## Identity Paths

### 1. Human access

Human operators authenticate through Microsoft Entra ID. Azure RBAC grants access to Azure resources and, later, to AKS administrative workflows.

Shared kubeconfigs are not the normal access path. Cluster access should be traceable to individual human identities or controlled automation identities.

### 2. GitHub Actions deployment access

GitHub Actions authenticates to Azure through OIDC federation to a dedicated Microsoft Entra deployment identity.

No GitHub client secrets should be stored for Azure access. Federation allows Azure to trust a specific GitHub repository, branch, environment, or workflow context without issuing a long-lived secret.

The deployment identity should receive only the permissions needed for the current Terraform layer.

### 3. Workload access to Key Vault

Pods use a Kubernetes ServiceAccount that is federated to Microsoft Entra Workload Identity. That federation allows the pod to act as a dedicated user-assigned managed identity.

The managed identity receives least-privilege Key Vault access for its workload boundary. Azure client secrets should not be placed in Kubernetes Secrets.

AKS cluster and kubelet identities must not be reused by applications. Platform identities and application identities need separate permissions and audit trails.

## Security Notes

- Use least privilege for humans, CI/CD identities, cluster identities, and workload identities.
- Keep separate identities for separate responsibilities.
- Avoid shared credentials because they weaken auditability and make rotation harder.
- Do not store Azure client secrets in GitHub or Kubernetes.
- Treat production controls as explicit architecture decisions, not implicit defaults.
