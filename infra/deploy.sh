LOCATION='swedencentral'

networkRGName='mtls-demo-network'
webappRGName='mtls-demo-webapp'
appgwRGName='mtls-demo-appgw'
vnetName='vnet-lz'
webappName='asp-demo'

az deployment sub create --location "$LOCATION" --template-file resourceGroups.bicep -n mtlsdemo --parameters networkRGName="$networkRGName" webappRGName="$webappRGName" appgwRGName="$appgwRGName"

az deployment group create --template-file vnet.bicep -n mtlsdemo-vnet -g "$networkRGName" --parameters location="$LOCATION" vnetName="$vnetName" --mode Complete
az deployment group create --template-file webapp.bicep -n mtlsdemo-webapp -g "$webappRGName" --parameters location="$LOCATION" webappName="$webappName" --mode Complete
az deployment group create --template-file appgw.bicep -n mtlsdemo-appgw -g "$appgwRGName" --parameters @appgwparams.json  --mode Complete