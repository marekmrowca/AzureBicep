using 'main.bicep'

// Common parameters
param location = 'Canada Central'
param userName = 'marek'
param userPassword = az.getSecret('ce0926bf-85d3-4a2f-b756-1140c6a3b3c5','rg-shared-test','kv-shared-testlab','adminUserPassword')

//// Choose one of the OS options and comment out the rest
//---------------------------------------------------------
// // Windows VM - image processing VM
param imageNicName = '${imageVmName}-nic'
param imageVmName = 'image-workload'
param imageOsDiskName = '${imageVmName}-disk'
param imageCompName = 'imagevm'
param imageVmCount = 1
param imageVmSize = 'Standard_B2als_v2'
param imageVmPublisher = 'MicrosoftWindowsServer'
param imageVmOffer = 'WindowsServer'
param imageVmSku = '2022-datacenter-smalldisk-g2'
param imageVmSkuVersion = 'latest'
param imageStorageAccountType = 'Standard_LRS'
param imageWebServerScriptContent = '''Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value "Image processing - $env:computername"
      '''
// // Windows VM - video processing VM
param videoNicName = '${videoVmName}-nic'
param videoVmName = 'video-workload'
param videoOsDiskName = '${videoVmName}-disk'
param videoCompName = 'videovm'
param videoVmCount = 1
param videoVmSize = 'Standard_B2ls_v2'
param videoVmPublisher = 'MicrosoftWindowsServer'
param videoVmOffer = 'WindowsServer'
param videoVmSku = '2025-datacenter-azure-edition-core-smalldisk'
param videoVmSkuVersion = 'latest'
param videoStorageAccountType = 'Standard_LRS'
param videoWebServerScriptContent = '''Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value "Video processing -$env:computername"
      '''

// Network parameters
param vnetName = 'mm-vnet'
param subnetWorkloadName = 'subnet-workload'
param subnetAppGwName = 'subnet-appgateway'
param nsgName = 'mm-nsg'
param pipName = 'mm-pip'
