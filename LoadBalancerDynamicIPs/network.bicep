param location string
param vnetName string
param subnetLbName string
param subnetWorkloadName string
param nsgName string
param nicName string
param vmCount int
param lbName string
var pipName = '${lbName}-pip'
var frontendName = '${lbName}-frontend'
var bpoolName = '${lbName}-bpool'
var lbrulesName = '${lbName}-lbrules'
var inatrulesName = '${lbName}-inatrules'
var healthName = '${lbName}-health'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnetWorkload 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  parent: virtualNetwork
  name: subnetWorkloadName
  properties: {
    addressPrefixes: [
      '10.0.0.0/24'
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource subnetLb 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  parent: virtualNetwork
  name: subnetLbName
  properties: {
    addressPrefixes: [
      '10.0.1.0/24'
    ] 
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: nsgName
  location: location
}

resource nsgrulerdp 'Microsoft.Network/networkSecurityGroups/securityRules@2025-01-01' = {
  name: 'AllowRDP'
  parent: networkSecurityGroup
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '82.177.199.243'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 1000
    direction: 'Inbound'
  }
}

resource nsgrulehttp 'Microsoft.Network/networkSecurityGroups/securityRules@2025-01-01' = {
  name: 'AllowHTTP'
  parent: networkSecurityGroup
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '82.177.199.243'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 900
    direction: 'Inbound'
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
    // inboundNatRules: [
    //   {
    //     name: inatrulesName
    //     properties: {
    //       backendAddressPool: {
    //         id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, bpoolName)
    //       }
    //       frontendIPConfiguration: {
    //         id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, frontendName)
    //       }
    //       protocol: 'Tcp'
    //       frontendPortRangeStart: 3390
    //       frontendPortRangeEnd: 3391
    //       backendPort: 3389
    //       enableFloatingIP: false
    //     }
    //   }
    // ]
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

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2025-01-01' = [for i in range(0, vmCount): {
  name: '${nicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetWorkload.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancerExternal.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}]

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


resource inboundNatRules 'Microsoft.Network/loadBalancers/inboundNatRules@2025-01-01' = {
  parent: loadBalancerExternal
  name: inatrulesName
    properties: {
    backendAddressPool: {
      id: loadBalancerExternal.properties.backendAddressPools[0].id
    }
    backendPort: 3389
    enableFloatingIP: false
    enableTcpReset: false
    frontendIPConfiguration: {
      id: loadBalancerExternal.properties.frontendIPConfigurations[0].id
    }
    frontendPortRangeEnd: 3390+vmCount
    frontendPortRangeStart: 3390
    idleTimeoutInMinutes: 5
    protocol: 'Tcp'
  }
}

output subnetWorkloadId string = subnetWorkload.id
output nicIds array = [for i in range(0, vmCount): networkInterfaces[i].id]
