param location string
param webappName string

resource diagnostic 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${webappName}diag'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

module appservice 'modules/appservice.bicep' = {
  name: 'appservice'
  params: {
    aspName: webappName
    location: location
    sku: 'S1'
    aspCapacity: 2

    webAppName: 'jk-webapp-demo'
  }
}
