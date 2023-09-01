locals {
    prefix-devops       = "devops-squad"
    devops-location       = "eastus"
    devops-resource-group = "rg-devops-squad"
}


variable "devops_apps" {
  type    = list
  default = [
    "app1",
    "app2"
    ]
}

locals {

  read_repos = [for value in var.devops_apps : "repositories/${local.prefix-devops}/${value}/content/read"]
  write_repos = [for value in var.devops_apps : "repositories/devops-squad/${value}/content/write"]
}

output "modified_values_list" {
  value = local.write_repos
}



data "azurerm_client_config" "current" {}

module "rg_devops_squad" {
  source  = "../modules/rg"
  name = local.devops-resource-group
  location = local.devops-location
}



module "akv_devops_squad" {
  source  = "../modules/akv"  
  name                            = "${local.prefix-devops}-vault"
  location                        = local.devops-location
  resource_group     = module.rg_devops_squad.name
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


module "acr_scope_map_devops_builder" {
  source                = "../modules/acr-scopes"
  scope_map_name        = "devops-squad-builder"
  container_registry_name = data.terraform_remote_state.azr-shared-services.outputs.acr_shared_name
  resource_group_name     = data.terraform_remote_state.azr-shared-services.outputs.rg_shared_name
  # actions = [
  #   "repositories/devops-squad/app1/content/read",
  #   "repositories/devops-squad/app1/content/write",
  #   "repositories/devops-squad/app2/content/read",
  #   "repositories/devops-squad/app2/content/write"
  # ]
  actions = concat(local.read_repos,local.write_repos)
  key_vault_id = module.akv_devops_squad.id
}