param location string
param vmName string
param osDiskName string
param nicName string
param compName string
param vmCount int
param userName string
@secure()
param userPassword string
param lbName string
param vnetName string
param subnetWorkloadName string
param subnetLbName string
param nsgName string

module network 'modules/network.bicep' = {
  name: 'mm-vnet-deployment'
  params: {
    location: location
    vnetName: vnetName
    subnetWorkloadName: subnetWorkloadName
    subnetLbName: subnetLbName
    nsgName: nsgName
    nicName: nicName
    vmCount: vmCount
    lbName: lbName
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
  }
}

