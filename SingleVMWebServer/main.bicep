param location string
// VM parameters
param vmName string
param osDiskName string
param compName string
param vmCount int
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
// Network parameters
param vnetName string
param subnetWorkloadName string
param nicName string
param nsgName string
param pipName string

module network 'modules/network.bicep' = {
  name: 'mm-vnet-deployment'
  params: {
    location: location
    vnetName: vnetName
    subnetWorkloadName: subnetWorkloadName
    nsgName: nsgName
    nicName: nicName
    vmCount: vmCount
    pipName: pipName
    }
}
module vm 'modules/vm.bicep' = {
  name: 'mm-vm-deployment'
  params: {
    location: location
    vmName: vmName
    compName: compName
    osDiskName: osDiskName
    nicIds: network.outputs.nicIds
    vmCount: vmCount
    userName: userName
    userPassword: userPassword
    vmSize: vmSize
    vmPublisher: vmPublisher
    vmOffer: vmOffer
    vmSku: vmSku
    vmSkuVersion: vmSkuVersion
    storageAccountType: storageAccountType
    webServerScriptContent: webServerScriptContent
  }
}

