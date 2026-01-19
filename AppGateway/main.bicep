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
// Network parameters
param vnetName string
param subnetWorkloadName string
param subnetAppGwName string
param nsgName string
param pipName string

module network 'modules/network.bicep' = {
  name: 'mm-vnet-deployment'
  params: {
    location: location
    vnetName: vnetName
    subnetWorkloadName: subnetWorkloadName
    subnetAppGwName: subnetAppGwName
    nsgName: nsgName
    pipName: pipName
    }
}
module imageVm 'modules/imageVm.bicep' = {
  name: 'mm-imagevm-deployment'
  params: {
    location: location
    userName: userName
    userPassword: userPassword
    imageNicName: imageNicName
    imageVmName: imageVmName
    imageCompName: imageCompName
    imageOsDiskName: imageOsDiskName
    imageVmCount: imageVmCount
    imageVmSize: imageVmSize
    imageVmPublisher: imageVmPublisher
    imageVmOffer: imageVmOffer
    imageVmSku: imageVmSku
    imageVmSkuVersion: imageVmSkuVersion
    imageStorageAccountType: imageStorageAccountType
    imageWebServerScriptContent: imageWebServerScriptContent
    subnetWorkloadId: network.outputs.subnetWorkloadId
  }
}

module videoVm 'modules/videoVm.bicep' = {
  name: 'mm-videovm-deployment'
  params: {
    location: location
    userName: userName
    userPassword: userPassword
    videoNicName: videoNicName
    videoVmName: videoVmName
    videoCompName: videoCompName
    videoOsDiskName: videoOsDiskName
    videoVmCount: videoVmCount
    videoVmSize: videoVmSize
    videoVmPublisher: videoVmPublisher
    videoVmOffer: videoVmOffer
    videoVmSku: videoVmSku
    videoVmSkuVersion: videoVmSkuVersion
    videoStorageAccountType: videoStorageAccountType
    videoWebServerScriptContent: videoWebServerScriptContent
    subnetWorkloadId: network.outputs.subnetWorkloadId
  }
}
