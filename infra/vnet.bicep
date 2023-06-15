targetScope = 'resourceGroup'

param location string
param vnetName string

module lzVnet 'modules/vnet.bicep' = {
  name: 'vnet-spoke'
  params: {
    location: location
    vnetName: vnetName
    subnets: [
      {
        name: 'appgw'
        properties: {
          addressPrefix: '10.13.0.0/24'
        }
      }
      {
        name: 'appservice-subnet'
        properties: {
          addressPrefix: '10.13.1.0/24'
        }
      }
      {
        name: 'pe-subnet'
        properties: {
          addressPrefix: '10.13.2.0/24'
        }
      }
      {
        name: 'vm-subnet'
        properties: {
          addressPrefix: '10.13.3.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.13.255.0/24'
        }
      }
    ]
    vnetAddressPrefix: '10.13.0.0/16'
  }
}
