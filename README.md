# Azure Bicep training
Set of projects for learning different Azure resources via Bicep. 
Modularize approach is taken. Advantages of using modules:

 1. Logical separation of resources: clear distinction between different resources and their functions. 
 2. Easier management and maintenance: easier way to refactor and replace parts of code. Easier to update. Reduced risks of implementing a bug. 
 3. Reusability: modules can be used in different projects.
 4. Improved scalability: infrastructure can be scaled up or down much faster if needed
 5. Improved troubleshooting: better readability helps to pinpoint errors and potential issues quicker.
## Sources
 
1. Bicep resource definitions - https://learn.microsoft.com/en-us/azure/templates/ 
2. Parametrize the deployment with a params file - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files?tabs=Bicep
3. Secret variables in Bicep can be used with KeyVault - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli 

## LoadBalancer**IPs
Test Standard Load Balancer with a pool of VMs.
### LoadBalancerDynamicIPs
IP allocation method for Network Interfaces is dynamic.
With Dynamic IP allocation methid I skipped definining LoadBalancer in a separate module to simplify the project, because BackendPool members can only be added in NIC resource. Therefore I defined LoadBalancer in network module together with the rest of network resources, including NIC.
### LoadBalancerStaticIPs
Another scenario to test could be that IP allocation method for Network Interfaces is static. In this scenario IPs could be assigned in a loop of loadBalancerBackendAddresses in LoadBalancer resource. 
### LoadBalancer creation limitations
Although it is a good practice to split child resources into separate resources (with "parent" field defined) it's not possible to create LoadBalancer's resources to create this way. It's Azure's limitation, therefore I created all LoadBalancers rules, probes, frontend configuration and backend pool inline in LoadBalancer's definition