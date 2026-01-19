param location string
param vnetName string
param subnetWorkloadName string
param subnetAppGwName string
param nsgName string
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

resource subnetAppGw 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  parent: virtualNetwork
  name: subnetAppGwName
  properties: {
    addressPrefixes: [
      '10.0.1.0/24'
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

resource nsgruleallowappgw 'Microsoft.Network/networkSecurityGroups/securityRules@2025-01-01' = {
  name: 'AllowAppGw'
  parent: networkSecurityGroup
  properties: {
    description: 'Allow Application Gateway v2 control plane'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '65200-65535'
    sourceAddressPrefix: 'AzureLoadBalancer'
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
  }
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
