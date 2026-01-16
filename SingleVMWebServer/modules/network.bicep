param location string
param vnetName string
param subnetWorkloadName string
param nsgName string
param nicName string
param vmCount int
param pipName string

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
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 1000
    direction: 'Inbound'
  }
}

resource nsgrulessh 'Microsoft.Network/networkSecurityGroups/securityRules@2025-01-01' = {
  name: 'AllowSSH'
  parent: networkSecurityGroup
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 990
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
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 900
    direction: 'Inbound'
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
          publicIPAddress: {
            id: publicIP.id
          }
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

output subnetWorkloadId string = subnetWorkload.id
output nicIds array = [for i in range(0, vmCount): networkInterfaces[i].id]
