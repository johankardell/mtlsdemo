targetScope = 'subscription'

param location string = deployment().location

param networkRGName string
param webappRGName string
param appgwRGName string


resource networkRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkRGName
  location: location
}

resource webappRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: webappRGName
  location: location
}

resource appgwRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: appgwRGName
  location: location
}
