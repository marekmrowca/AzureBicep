param location string
param vmName string
param osDiskName string
param compName string
param vmCount int
param nicIds array
param userName string
@secure() 
param userPassword string
var scriptName = '${vmName}-installWebServer'

resource windowsVM 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, vmCount): {
  name: '${vmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ls_v2'
    }
    osProfile: {
      computerName: '${compName}-${i}'
      adminUsername: userName
      adminPassword: userPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${osDiskName}-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
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
  parent: windowsVM[i]
  properties: {
    asyncExecution: false
    source: {
      script: '''
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value $env:computername
      '''
    }
  }
}]

