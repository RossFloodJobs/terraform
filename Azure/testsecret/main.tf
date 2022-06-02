provider "azurerm" {
    version = "2.92.0"
  features {}
}

variable "KV" {} #This will pull in value from TF_VAR_KV set in environment variable

data "azurerm_key_vault_secret" "GetPassword" {
  name = "SamplePassword"
  key_vault_id = "${var.KV}"
}

resource "azurerm_key_vault_secret" "WritePassword" {
  name = "newPassword"
  value = data.azurerm_key_vault_secret.GetPassword.value
  key_vault_id = "${var.KV}"
}

output "Secret_From_KeyVault" {
    value = data.azurerm_key_vault_secret.GetPassword.value
    sensitive = true
}