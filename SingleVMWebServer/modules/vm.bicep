param location string
param vmName string
param osDiskName string
param compName string
param vmCount int
param nicIds array
param userName string
@secure() 
param userPassword string
param vmSize string
param vmPublisher string
param vmOffer string
param vmSku string
param vmSkuVersion string
param storageAccountType string
param webServerScriptContent string
var scriptName = '${vmName}-installWebServer'

resource workloadVM 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, vmCount): {
  name: '${vmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${compName}-${i}'
      adminUsername: userName
      adminPassword: userPassword
    }
    storageProfile: {
      imageReference: {
        publisher: vmPublisher
        offer: vmOffer
        sku: vmSku
        version: vmSkuVersion
      }
      osDisk: {
        name: '${osDiskName}-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicIds[i]
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

resource installWebServer 'Microsoft.Compute/virtualMachines/runCommands@2025-04-01' = [for i in range(0, vmCount): {
  name: '${scriptName}-${i}'
  location: location
  parent: workloadVM[i]
  properties: {
    asyncExecution: false
    source: {
      script: webServerScriptContent
    }
  }
}]

