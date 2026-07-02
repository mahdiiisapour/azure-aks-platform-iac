#!/usr/bin/env bash
set -Eeuo pipefail

# Destroys only disposable Azure lab layers.
# It intentionally NEVER touches protected persistent layers:
# - infra/00-bootstrap: Terraform remote-state storage
# - infra/10-foundation: persistent dev platform resource group

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INFRA_ROOT="${REPO_ROOT}/infra"

# Keep layers in reverse dependency order.
# Add any future disposable layer at the TOP.
LAYERS=(
  "50-security"
  "40-observability"
  "30-aks"
  "20-network"
)

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v terraform >/dev/null 2>&1 || fail "terraform is not installed or not in PATH."
command -v az >/dev/null 2>&1 || fail "Azure CLI is not installed or not in PATH."

[[ -n "${ARM_SUBSCRIPTION_ID:-}" ]] || fail \
  "ARM_SUBSCRIPTION_ID is not set. Enter the repository folder so direnv loads .envrc."

ACTIVE_SUBSCRIPTION_ID="$(az account show --query id --output tsv 2>/dev/null || true)"

[[ -n "${ACTIVE_SUBSCRIPTION_ID}" ]] || fail \
  "Azure CLI is not logged in. Run: az login"

[[ "${ACTIVE_SUBSCRIPTION_ID}" == "${ARM_SUBSCRIPTION_ID}" ]] || fail \
  "Azure CLI and Terraform are targeting different subscriptions.

Azure CLI subscription: ${ACTIVE_SUBSCRIPTION_ID}
Terraform subscription: ${ARM_SUBSCRIPTION_ID}

Run:
az account set --subscription \"${ARM_SUBSCRIPTION_ID}\""

# Prevent AzureRM from attempting to auto-register many providers.
export ARM_RESOURCE_PROVIDER_REGISTRATIONS=none

echo "Azure subscription: $(az account show --query name --output tsv)"
echo "Repository: ${REPO_ROOT}"
echo "Protected layers:"
echo "- infra/00-bootstrap"
echo "- infra/10-foundation"
echo

for LAYER in "${LAYERS[@]}"; do
  LAYER_DIR="${INFRA_ROOT}/${LAYER}"

  if [[ ! -d "${LAYER_DIR}" ]]; then
    echo "Skipping ${LAYER}: directory does not exist."
    continue
  fi

  if ! find "${LAYER_DIR}" -maxdepth 1 -name "*.tf" -print -quit | grep -q .; then
    echo "Skipping ${LAYER}: no Terraform files yet."
    continue
  fi

  echo
  echo "============================================================"
  echo "Destroying layer: ${LAYER}"
  echo "Directory: ${LAYER_DIR}"
  echo "============================================================"

  pushd "${LAYER_DIR}" >/dev/null

  terraform init -input=false -no-color

  STATE_RESOURCES="$(terraform state list 2>/dev/null || true)"

  if [[ -z "${STATE_RESOURCES}" ]]; then
    echo "Skipping ${LAYER}: Terraform state has no managed resources."
    popd >/dev/null
    continue
  fi

  terraform destroy \
    -auto-approve \
    -input=false \
    -lock-timeout=5m \
    -no-color

  popd >/dev/null
done

echo
echo "Destroy completed."
echo "Protected layers were not touched:"
echo "- infra/00-bootstrap"
echo "- infra/10-foundation"
