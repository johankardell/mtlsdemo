// Docs: https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/quick-create-bicep?tabs=CLI

param name string
param subnetId string
param location string

param backendfqdn string

var pipAppgwName = 'pip-${name}'

resource pipappgw 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: pipAppgwName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'jk-demo-${name}'
    }
  }
}

resource appgwFWPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-11-01' = {
  name: 'waf-${name}'
  location: location
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
        }
      ]
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-11-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'feconfig'
        properties: {
          publicIPAddress: {
            id: pipappgw.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool'
        properties: {
          backendAddresses: [
            {
              fqdn: backendfqdn
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'beprobe'
        properties: {
          pickHostNameFromBackendHttpSettings: true
          interval: 20
          timeout: 60
          protocol: 'Https'
          path: '/'
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'behttpsettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: backendfqdn
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'beprobe')
          }
          probeEnabled: true
        }
      }
    ]
    httpListeners: [
      {
        name: 'httplistener'
        properties: {
          firewallPolicy: {
            id: appgwFWPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, 'feconfig')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port_80')
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routerule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'httplistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'bepool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'behttpsettings')
          }
        }
      }
    ]
  }
}
