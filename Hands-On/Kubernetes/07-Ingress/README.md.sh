# Ingress - Basics

## Introduction

# Get the resource group name of the AKS cluster
AKS_NAME="aksatin"
AKS_RG="rgaksatin"

az aks get-credentials --name $AKS_NAME --resource-group $AKS_RG --admin

CLSTR_RG_NAME=$(az aks show --resource-group $AKS_RG --name $AKS_NAME --query nodeResourceGroup -o json)
CLSTR_RG_NAME2=${CLSTR_RG_NAME//\"}
echo $CLSTR_RG_NAME2

# Create Public IP
INGRESS_PUB_IP=$(az network public-ip create --resource-group $CLSTR_RG_NAME2 --name myAKSPublicIPForIngress --sku Basic --allocation-method static --query publicIp.ipAddress -o json)
INGRESS_PUB_IP2=${INGRESS_PUB_IP//\"}
echo $INGRESS_PUB_IP2

#- Make a note of Static IP which we will use in next step when installing Ingress Controller

# Make a note of Public IP created for Ingress
#52.154.156.139

# Install Helm3 (if not installed)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Create a namespace for your ingress resources
kubectl delete namespace ingress-basic
kubectl create namespace ingress-basic

# Add the official stable repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo add stable https://charts.helm.sh/stable/


helm repo update


#  Customizing the Chart Before Installing.
helm show values ingress-nginx/ingress-nginx

# If required
#helm uninstall ingress-nginx  --namespace ingress-basic

# Use Helm to deploy an NGINX ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP=$INGRESS_PUB_IP2


# List Services with labels
kubectl get service -l app.kubernetes.io/name=ingress-nginx --namespace ingress-basic
kubectl describe service -l app.kubernetes.io/name=ingress-nginx --namespace ingress-basic


# List Pods
kubectl get pods -n ingress-basic


kubectl get all -n ingress-basic

kubectl get service ingress-nginx-controller --namespace ingress-basic

LOAD_BALANCER_IP=$(kubectl get service ingress-nginx-controller --namespace ingress-basic -o json | jq .spec.loadBalancerIP)
LOAD_BALANCER_IP2=${LOAD_BALANCER_IP//\"}
echo $LOAD_BALANCER_IP2

# Access Public IP
curl http://<Public-IP-created-for-Ingress>
curl $LOAD_BALANCER_IP2

# Output should be
# 404 Not Found from Nginx

#- Verify Load Balancer on Azure Mgmt Console
#  - Primarily refer Settings -> Frontend IP Configuration

## Review Application k8s manifests
#- 01-NginxApp1-Deployment.yml
#- 02-NginxApp1-ClusterIP-Service.yml
#- 03-Ingress-Basic.yml

## Deploy Application k8s manifests and verify

# Deploy
kubectl apply -f kube-manifests/


# List Pods
kubectl get pods


# List Services
kubectl get svc


# List Ingress
kubectl get ingress


# Access Application
curl http://$LOAD_BALANCER_IP2/app1/index.html


curl http://$LOAD_BALANCER_IP2


# Verify Ingress Controller Logs
kubectl get pods -n ingress-basic


kubectl logs -f <pod-name> -n ingress-basic


## Clean-Up Apps

# Delete Apps
kubectl delete -f kube-manifests/
