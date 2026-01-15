using 'main.bicep'

param location = 'Canada Central'
param vmName = 'mm-vm-workload'
param osDiskName = '${vmName}-disk'
param nicName = '${vmName}-nic'
param compName = 'workload'
param vmCount = 2
param userName = 'marek'
param userPassword = az.getSecret('ce0926bf-85d3-4a2f-b756-1140c6a3b3c5','rg-shared-test','kv-shared-testlab','adminUserPassword')
param lbName = 'mm-lb'
param vnetName = 'mm-vnet'
param subnetWorkloadName = 'subnet-workload'
param subnetLbName = 'subnet-lb'
param nsgName = 'mm-nsg'
