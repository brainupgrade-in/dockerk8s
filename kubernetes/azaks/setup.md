# Create AKS cluster

export CLUSTER_NAME="boatest_rg"
export RESOURCE_GROUP_NAME="boatest_group"
export REGION="centralindia"
export ADMIN_USERNAME=azaksadm
export DNS_LABEL="dnslabel"
export DOMAIN_NAME=gheware.com
export PRIVATE_DOMAIN=k8s.gheware.com

az login 

az aks create --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --enable-managed-identity --generate-ssh-keys --node-vm-size Standard_B2s --node-count 1 --nodepool-name agentpool --load-balancer-sku standard --enable-cluster-autoscaler --min-count 1 --max-count 2 --network-plugin azure --network-policy azure --admin-username $ADMIN_USERNAME --location $REGION

# Get kubeconfig
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

# Add spot nodepool
az aks nodepool add --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name np1  --node-vm-size Standard_B2s_v2 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 5 --max-pods 110 --mode User --priority Spot --eviction-policy Delete --spot-max-price -1 --no-wait

az aks nodepool add --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name np2  --node-vm-size Standard_B2ps_v2 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 5 --max-pods 110 --mode User  --no-wait

az aks nodepool add --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name npb2ms  --node-vm-size Standard_B2ms --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 5 --max-pods 110 --mode System  --no-wait

az aks nodepool delete --name np2 --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME

az aks nodepool update --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name np2  --min-count 1 --max-count 10  --mode User --update-cluster-autoscaler  --no-wait

az aks nodepool list --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME

# Autoscaler - Misc
kubectl get events --field-selector source=cluster-autoscaler,reason=NotTriggerScaleUp
kubectl get configmap -n kube-system cluster-autoscaler-status -o yaml

# Enable RBAC
az aks update -g $RESOURCE_GROUP_NAME -n $CLUSTER_NAME --enable-azure-rbac --enable-aad 

# AKS AAD - Add Users
check google classroom

# Kubernetes RBAC
Add Role and RoleBinding for the users added in the AKS AAD

# Certificates
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml

# App routing - ingress controller
az aks approuting enable -g $RESOURCE_GROUP_NAME -n $CLUSTER_NAME

ZONEID=$(az network dns zone show --resource-group $RESOURCE_GROUP_NAME --name $DOMAIN_NAME --query "id" --output tsv)

az aks approuting zone add --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --ids=${ZONEID} --attach-zones


# Non-interactive login

az ad sp create-for-rbac --name {ServicePrincipalName}

az login --service-principal -u [APP_ID] -p [PASSWORD] --tenant [TENANT_ID]

az ad sp create-for-rbac --name aksadm
 
az login --service-principal -u <Service-Principal-AppID> -p <pwd> --tenant <tenant>


az ad sp list --show-mine --query "[].{id:appId, name:displayName}"

az role assignment create --assignee <Service-Principal-AppID> --role "Azure Kubernetes Service Cluster Reader Role" --scope /subscriptions/{SubId}/resourcegroups/{ResourceGroupName}/providers/Microsoft.ContainerService/managedClusters/{ClusterName}

az role assignment list --assignee <Service-Principal-AppID> --query "[].{role:roleDefinitionName, scope:scope}"

# Get AKS ID
AKS_ID=$(az aks show -g $RESOURCE_GROUP_NAME -n ${CLUSTER_NAME} --query id -o tsv)



# SP for mtvlabk8su
az ad sp create-for-rbac --name <role-name>

az role definition create --role-definition aks-cluster-reader-role.json

az role assignment create --assignee <Service-Principal-AppID> --role <role name defined in json> --scope <cluster-url>

az login --service-principal -u <Service-Principal-AppID> -p <pwd> --tenant <tenant>

az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

# role definition 
az role definition create --role-definition aks-cluster-reader-role.json

# Delete Cluster
az aks  delete --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME

# DNS setup - optional
az network vnet create --name myAzureVNet --resource-group $RESOURCE_GROUP_NAME --location $REGION --address-prefix 10.2.0.0/16 --subnet-name mysubnet --subnet-prefixes 10.2.0.0/24

az network private-dns zone create --resource-group $RESOURCE_GROUP_NAME -n $PRIVATE_DOMAIN

az network private-dns link vnet create --resource-group $RESOURCE_GROUP_NAME --name myDNSLink --zone-name $DOMAIN_NAME --virtual-network myAzureVNet --registration-enabled false

ZONEID=$(az network private-dns zone show --resource-group $RESOURCE_GROUP_NAME --name $PRIVATE_DOMAIN --query "id" --output tsv)

az aks approuting zone add --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --ids=${ZONEID} --attach-zones

az network private-dns record-set a list --resource-group $RESOURCE_GROUP_NAME --zone-name $PRIVATE_DOMAIN
