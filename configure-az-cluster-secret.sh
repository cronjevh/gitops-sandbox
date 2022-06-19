# Depends on 
#   az cli https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#   kubectl
#   kubectl context to k8s cluster with cluster-admin
# Using Local Cluster secret instead of AAD Pod Identity according to https://techcommunity.microsoft.com/t5/azure-global/gitops-and-secret-management-with-aks-flux-cd-sops-and-azure-key/ba-p/2280068
# Azure ARC with AAD integration https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/azure-rbac
CLUSTER_NAME=docker-desktop

SERVER_APP_ID=$(az ad app create --display-name "${CLUSTER_NAME}Server" --identifier-uris "api://${TENANT_ID}/ClientAnyUniqueSuffix" --query appId -o tsv)


# from https://github.com/fluxcd/kustomize-controller/blob/main/docs/spec/v1beta2/kustomization.md#azure-key-vault-secret-entry
SUBSCRIPTION_ID=$(az account list --query '[?isDefault].id' -o tsv)
TENANT_ID=$(az account list --query '[?isDefault].tenantId' -o tsv)

SP_CRED=$(az ad sp create-for-rbac --name docker-desktop-keyvault-reader)
echo $SP_CRED > .secret.json
kubectl create secret generic sops-keys --from-literal -n flux-system "sops.azure-kv=$SP_CRED"

SOPS_KID=$(az keyvault key show --name sops-key --vault-name $KEY_VAULT_NAME --query key.kid)