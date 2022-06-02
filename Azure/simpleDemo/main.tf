#Define providers used
provider "azurerm" {
    version = "2.92.0"
    features {} #This is required for v2 of the provider even if empty or plan will fail
}

#Data section
data "azurerm_resource_group" "resource_group" {
  name = "rflood-demo-rg"
}

#Resource section
resource "azurerm_storage_account" "storageaccount01" {
  name                     = "rflooddemo"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replicationType
}

resource "azurerm_storage_container" "images_container" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storageaccount01.name
  container_access_type = "private"
}

