locals {
    prefix-online       = "online-squad"
    online-location       = "eastus"
    online-resource-group = "rg-online-squad"
}


variable "online_apps" {
  type    = list
  default = [
    "online-app1",
    "online-app2"
    ]
}

locals {

  read_repos = [for value in var.online_apps : "repositories/${local.prefix-online}/${value}/content/read"]
  write_repos = [for value in var.online_apps : "repositories/${local.prefix-online}/${value}/content/write"]
}

output "modified_values_list" {
  value = local.write_repos
}



data "azurerm_client_config" "current" {}

module "rg_online_squad" {
  source  = "../modules/rg"
  name = local.online-resource-group
  location = local.online-location
}



module "akv_online_squad" {
  source  = "../modules/akv"  
  name                            = "${local.prefix-online}-vault"
  location                        = local.online-location
  resource_group     = module.rg_online_squad.name
  tenant_id = data.azurerm_client_config.current.tenant_id


  access_policies = [
    {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = data.azurerm_client_config.current.object_id
      key_permissions    = ["Get", "List", "Encrypt", "Decrypt", "Create"]
      secret_permissions    = [ "Get", "List", "Delete", "Set"]
      storage_permissions    = ["Get"]
    },
    {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = var.my_ui_account_object_id
      secret_permissions    = [ "Get", "List", "Set"]
      key_permissions    = []
      storage_permissions    = []
    }
    # Add more access policies as needed
  ]

}



####


module "acr_scope_map_online_builder" {
  source                = "../modules/acr-scopes"
  scope_map_name        = "online-squad-builder"
  container_registry_name = data.terraform_remote_state.azr-shared-services.outputs.acr_shared_name
  resource_group_name     = data.terraform_remote_state.azr-shared-services.outputs.rg_shared_name
  actions = concat(local.read_repos,local.write_repos)
  key_vault_id = module.akv_online_squad.id
}