### The techniques used in this demo are documented at
### https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/

### Import AzureRM.Profile and AzureRM.Resources modules
### Make sure the folder you copied them to is in $ENV:PSModulePath
Import-Module AzureRM.NetCore.Preview

### Supply your Azure Credentials
Login-AzureRMAccount

### Creating a New Azure Resource Group 
New-AzureRMResourceGroup -Name PSAug18 -Location "West US"

### Deploy an Ubuntu 14.04 VM using Resource Manager cmdlets
### Template is available is at 
### http://armviz.io/#/?load=https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json
# $password = Convertto-Securestring -String "PowerShellRocks!" -AsPlainText -Force
New-AzureRMResourceGroupDeployment -ResourceGroupName PSAug18 -TemplateFile ./Compute-Linux.json -adminUserName psuser  -adminPassword "PowerShellRocks!"  -dnsLabelPrefix psaug18ubuntu

### Monitor the status of the deployment
Get-AzureRMResourceGroupDeployment -ResourceGroupName PSAug18

### Discover the resources we created by the previous deployment
Find-AzureRMResource -ResourceGroupName PSAug18 | select Name,ResourceType,Location

### Get the state of the VM we created
### Notice: The VM is in running state
Get-AzureRMResource -ResourceName MyUbuntuVM  -ResourceType Microsoft.Compute/virtualMachines -ResourceGroupName PSAug18 -ODataQuery '$expand=instanceView' | % properties | % instanceview | % statuses

### Discover the Operations we can perform on the compute resource
### Notice: Operations like "Power Off Virtual Machine", "Start Virtual Machine", "Create Snapshot", "Delete Snapshot", "Delete Virtual Machine"
Get-AzureRMProviderOperation -OperationSearchString Microsoft.Compute/* | select  OperationName,Operation

### Power Off the Virtual Machine we created
Invoke-AzureRmResourceAction -ResourceGroupName PSAug18 -ResourceType Microsoft.Compute/virtualMachines -ResourceName MyUbuntuVM -Action poweroff 

### Check the VM State again. It should be stopped now.
Get-AzureRMResource -ResourceName MyUbuntuVM  -ResourceType Microsoft.Compute/virtualMachines -ResourceGroupName PSAug18 -ODataQuery '$expand=instanceView' | % properties | % instanceview | % statuses

### As you know, you may still be incurring charges even if the VM is in stopped state
### Deallocate the resource to avoid this charge
Invoke-AzureRmResourceAction -ResourceGroupName PSAug18 -ResourceType Microsoft.Compute/virtualMachines -ResourceName MyUbuntuVM -Action deallocate 

### The following command removes the Virtual Machine
Remove-AzureRmResource -ResourceName MyUbuntuVM -ResourceType Microsoft.Compute/virtualMachines -ResourceGroupName PSAug18

### Look at the resources that still exists
Find-AzureRMResource -ResourceGroupName PSAug18 | select Name,ResourceType,Location

### Remove the ResourceGroup which removes all the resources in the ResourceGroup
Remove-AzureRmResourceGroup -Name PSAug18