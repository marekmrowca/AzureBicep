var location = 'Canada Central'
var vmName = 'mm-vm-workload'
var osDiskName = '${vmName}-disk'
var nicName = '${vmName}-nic'
var compName = 'workload'
var vmCount = 2
var userName = 'marek'
var lbName = 'mm-lb'

// module lb 'loadbalancer.bicep' = {
//   name: 'mm-lb-deployment'
//   params: {
//     location: location
//     lbName: lbName
//   }
// }
module network 'network.bicep' = {
  name: 'mm-vnet-deployment'
  params: {
    location: location
    vnetName: 'mm-vnet'
    subnetWorkloadName: 'subnet-workload'
    subnetLbName: 'subnet-lb'
    nsgName: 'mm-nsg'
    nicName: nicName
    vmCount: vmCount
    lbName: lbName
    // lbbackendpoolId: lb.outputs.lbbackendpoolId  
    }
}
module vm 'vm.bicep' = {
  name: 'mm-vm-deployment'
  params: {
    location: location
    vmName: vmName
    compName: compName
    osDiskName: osDiskName
    nicIds: network.outputs.nicIds
    vmCount: vmCount
    userName: userName
  }
}

