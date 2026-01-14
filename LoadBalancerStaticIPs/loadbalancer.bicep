param location string
param lbName string
var pipName = '${lbName}-pip'
var frontendName = '${lbName}-frontend'
var bpoolName = '${lbName}-bpool'
var lbrulesName = '${lbName}-lbrules'
var inatrulesName = '${lbName}-inatrules'
var healthName = '${lbName}-health'


resource publicIP 'Microsoft.Network/publicIPAddresses@2025-01-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: pipName
    }
  }
} 

resource loadBalancerExternal 'Microsoft.Network/loadBalancers@2025-01-01' = {
  name: lbName
  location: location
  sku: {
    tier: 'Regional'
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: bpoolName
      }
    ]
    inboundNatRules: [
      {
        name: inatrulesName
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, bpoolName)
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, frontendName)
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 3390
          frontendPortRangeEnd: 3391
          backendPort: 3389
          enableFloatingIP: false
        }
      }
    ]
    loadBalancingRules: [
      {
        name: lbrulesName
        properties: {
          frontendIPConfiguration: {
             id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, frontendName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, bpoolName)
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, healthName)
          }
        }
      }
    ]
    probes: [
      {
        name: healthName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

output lbbackendpoolId string = loadBalancerExternal.properties.backendAddressPools[0].id
output loadBalancer object = loadBalancerExternal
