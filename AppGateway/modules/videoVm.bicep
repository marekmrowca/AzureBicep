// Common parameters
param location string
param userName string
@secure() 
param userPassword string
// Video processing VMs
param videoNicName string
param videoVmName string
param videoOsDiskName string
param videoCompName string
param videoVmCount int
param videoVmSize string
param videoVmPublisher string
param videoVmOffer string
param videoVmSku string
param videoVmSkuVersion string
param videoStorageAccountType string
param videoWebServerScriptContent string
param subnetWorkloadId string
var scriptName = '${videoVmName}-installWebServer'

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2025-01-01' = [for i in range(0, videoVmCount): {
  name: '${videoNicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetWorkloadId
          }
        }
      }
    ]
  }
}]

resource videoWorkloadVM 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, videoVmCount): {
  name: '${videoVmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: videoVmSize
    }
    osProfile: {
      computerName: '${videoCompName}-${i}'
      adminUsername: userName
      adminPassword: userPassword
    }
    storageProfile: {
      imageReference: {
        publisher: videoVmPublisher
        offer: videoVmOffer
        sku: videoVmSku
        version: videoVmSkuVersion
      }
      osDisk: {
        name: '${videoOsDiskName}-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: videoStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
          properties:{
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}]

resource videoInstallWebServer 'Microsoft.Compute/virtualMachines/runCommands@2025-04-01' = [for i in range(0, videoVmCount): {
  name: '${scriptName}-${i}'
  location: location
  parent: videoWorkloadVM[i]
  properties: {
    asyncExecution: false
    source: {
      script: videoWebServerScriptContent
    }
  }
}]
