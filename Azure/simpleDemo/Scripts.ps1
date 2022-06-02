$env:SubID = '9729361a-8a09-4ad7-95cb-b7c2e66859f8'


New-AzResourceGroup -Location southcentralus -Name 'rflood-demo-rg'
#SP Creation 
#https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SubID"
$GitBasePath = C:\Workspace\terraformFiles\
Set-Location $GitBasePath\Azure

terraform fmt  #make my files formatted correctly and will fix all tf files in this folder

terraform init
terraform plan #<-view changes that will be applied
terraform apply -auto-approve

#Human readable view of the state file
terraform show

#Show specific resource from state file
terraform state list
terraform state show azurerm_storage_account.storageaccount01
terraform state show azurerm_storage_container.images_container

terraform plan -var 'replicationType=GRS'
terraform apply -var 'replicationType=GRS' -auto-approve

#To visually see
terraform graph > base.dot
# could sent directly with graphviz installed https://graphviz.gitlab.io/download/
terraform graph | dot -Tsvg > graph.svg

#If resources changed outside of terraform and state not current
terraform refresh

#For secrets
Set-Location $GitBasePath\SecretOnly
#Set variable to avoid having in my source files. Could also use terraform.tfvars etc
$env:TF_VAR_KV="/subscriptions/$env:SubID/resourceGroups/vault-rg/providers/Microsoft.KeyVault/vaults/top-vault"

terraform init
terraform plan
terraform apply


#To delete the resources
terraform plan -destroy -out='planout'   #Is there a file type to use? .tfplan??
terraform apply 'planout'
#or
terraform destroy