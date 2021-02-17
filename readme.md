# Infrastructure as Code via GitOps example

## Front door demo guide
curl project1-aks-we.westeurope.cloudapp.azure.com
curl project1-aks-ne.northeurope.cloudapp.azure.com

### From Prague edge westeurope is more likely to be selected due to lower latency
curl tomasdoor123.azurefd.net  

### Start continuous check
while true; do curl tomasdoor123.azurefd.net; done

### Disable app in westeurope and observe speed of failover
az aks get-credentials -g project1-we-rg -n aks-project1-aks-we --admin --overwrite
kubectl scale --replicas=0 deploy/myweb-deployment   # traffic will switch to northeurope
kubectl scale --replicas=2 deploy/myweb-deployment   # traffic will switch back to westeurope

# Hostile destroy
az group delete -y --no-wait -n project1-ne-rg
az group delete -y --no-wait -n project1-we-rg
az group delete -y --no-wait -n networking-rg
az storage blob delete --account-name tomuvstore -c tstate-gitops -n terraform.tfstate