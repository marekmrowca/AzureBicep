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

## SingleVMWebServer
I copied two modules from LoadBalancerDynamicIPs project just to create a custom VM's web server.
### Important note
I left vmCount parameter and loops for creating VMs, NICs, but it won't work for vmCount > 1 in the current setup, because there's no loop for creating public IP addresses.
### Web servers
Choose between different OS offers in main.bicepparam
### Bicep, idempotency and configuration management
Bicep is repoonsible for Azure resources creation and upon each run it checks if resources exists or not. It doesn't verify OS content, like web server configuration. 
#### Example - web server configuration idempotency check
I created a Linux VM with nginx installed and configured with custom HTML page. Then I manually removed nginx and rerun the Bicep deployment. It didn't discover, that nginx is no longer installed. 
#### Conclusion
Bicep is typically for infrastructure management. It can detect existence or lack of Azure resources, but not how they're configured.
For configuration management it's better to use dedicated tools like Ansible. 
### RunCommand resource for PowerShell and Bash
RunCommand resource runs smoothly with IIS and PowerShell script, but it fails with Bash. I tried different tricks, but it was constantly failing to execute bash commands to install and confiugre nginx. 