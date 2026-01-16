using 'main.bicep'

param location = 'Canada Central'
// VM parameters
param vmName = 'mm-vm-workload'
param osDiskName = '${vmName}-disk'
param compName = 'workload'
param vmCount = 1
param userName = 'marek'
param userPassword = az.getSecret('ce0926bf-85d3-4a2f-b756-1140c6a3b3c5','rg-shared-test','kv-shared-testlab','adminUserPassword')

//// Choose one of the OS options and comment out the rest
//---------------------------------------------------------
// // Windows VM
param vmSize = 'Standard_B2ls_v2'
param vmPublisher = 'MicrosoftWindowsServer'
param vmOffer = 'WindowsServer'
param vmSku = '2022-datacenter-smalldisk-g2'
param vmSkuVersion = 'latest'
param storageAccountType = 'Standard_LRS'
param webServerScriptContent = '''Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value $env:computername
      '''
// // Linux VM
// param vmSize = 'Standard_B2ls_v2'
// param vmPublisher = 'Canonical'
// param vmOffer = 'ubuntu-25_10'
// param vmSku = 'minimal'
// param vmSkuVersion = 'latest'
// param storageAccountType = 'Standard_LRS'
// //bash script doesn't execute with runCommand resource, so it needs to be run manually afer VM's creation
// param webServerScriptContent = '''sudo bash -c '
//         set -eux
//         apt-get update
//         apt-get install -y nginx
//         rm -f /var/www/html/*
//         echo $(hostname) | tee /var/www/html/index.html'
//       '''
//---------------------------------------------------------
      // Network parameters
param vnetName = 'mm-vnet'
param subnetWorkloadName = 'subnet-workload'
param nicName = '${vmName}-nic'
param nsgName = 'mm-nsg'
param pipName = 'mm-pip'
