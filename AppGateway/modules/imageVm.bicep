// Common parameters
param location string
param userName string
@secure() 
param userPassword string
// Image processing VMs
param imageNicName string
param imageVmName string
param imageOsDiskName string
param imageCompName string
param imageVmCount int
param imageVmSize string
param imageVmPublisher string
param imageVmOffer string
param imageVmSku string
param imageVmSkuVersion string
param imageStorageAccountType string
param imageWebServerScriptContent string
param subnetWorkloadId string
var scriptName = '${imageVmName}-installWebServer'

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2025-01-01' = [for i in range(0,imageVmCount): {
  name: '${imageNicName}-${i}'
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

resource imageWorkloadVM 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, imageVmCount): {
  name: '${imageVmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: imageVmSize
    }
    osProfile: {
      computerName: '${imageCompName}-${i}'
      adminUsername: userName
      adminPassword: userPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imageVmPublisher
        offer: imageVmOffer
        sku: imageVmSku
        version: imageVmSkuVersion
      }
      osDisk: {
        name: '${imageOsDiskName}-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: imageStorageAccountType
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

resource imageInstallWebServer 'Microsoft.Compute/virtualMachines/runCommands@2025-04-01' = [for i in range(0, imageVmCount): {
  name: '${scriptName}-${i}'
  location: location
  parent: imageWorkloadVM[i]
  properties: {
    asyncExecution: false
    source: {
      script: imageWebServerScriptContent
    }
  }
}]
