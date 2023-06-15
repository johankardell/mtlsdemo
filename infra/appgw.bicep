param webappFQDN string
param vnetName string
param networkRGName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetName
  scope: resourceGroup(networkRGName)
}

module appgw 'modules/appgw.bicep' = {
  name: 'appgw'
  params: {
    name: 'appgw'
    location: location
    subnetId: vnet.properties.subnets[0].id
    backendfqdn: webappFQDN
  }
}
