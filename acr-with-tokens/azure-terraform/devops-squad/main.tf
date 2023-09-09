# Define locals for prefix, location, and resource group

locals {
  prefix-devops         = "devops-squad"
  devops-location       = "eastus"
  devops-resource-group = "rg-devops-squad"
}

# Define a variable for devops_apps with a default value
variable "devops_apps" {
  type = list(any)
  default = [
    "app1",
    "app2"
  ]
}

# Define locals for read_repos and write_repos
locals {
  read_repos  = [for value in var.devops_apps : "repositories/${local.prefix-devops}/${value}/content/read"]
  write_repos = [for value in var.devops_apps : "repositories/${local.prefix-devops}/${value}/content/write"]
}

# Define an output to display modified values list
output "modified_values_list" {
  value = local.write_repos
}

# Get the current Azure client configuration
data "azurerm_client_config" "current" {}

# Create a module for the devops-squad resource group
module "rg_devops_squad" {
  source   = "../modules/rg"
  name     = local.devops-resource-group
  location = local.devops-location
}



# Create a module for the devops-squad Azure Key Vault
module "akv_devops_squad" {
  source         = "../modules/akv"
  name           = "${local.prefix-devops}-vault"
  location       = local.devops-location
  resource_group = module.rg_devops_squad.name
  tenant_id      = data.azurerm_client_config.current.tenant_id


  access_policies = [
    {
      # This is to grant AKV permissions to my terraform service principal so
      # that it can update secret values 
      tenant_id           = data.azurerm_client_config.current.tenant_id
      object_id           = data.azurerm_client_config.current.object_id
      key_permissions     = ["Get", "List", "Encrypt", "Decrypt", "Create"]
      secret_permissions  = ["Get", "List", "Delete", "Set"]
      storage_permissions = ["Get"]
    },
    {
      # This is to grant AKV permission to my azure web console user 
      # that it can read the secret values from web for this demo purpose
      tenant_id           = data.azurerm_client_config.current.tenant_id
      object_id           = var.my_ui_account_object_id
      secret_permissions  = ["Get", "List", "Set"]
      key_permissions     = []
      storage_permissions = []
    }
    # Add more access policies as needed
  ]

}



#### builder scope ####
module "acr_scope_map_devops_builder" {
  source                  = "../modules/acr-scopes"
  scope_map_name          = "devops-squad-builder"
  container_registry_name = data.terraform_remote_state.azr-shared-services.outputs.acr_shared_name
  resource_group_name     = data.terraform_remote_state.azr-shared-services.outputs.rg_shared_name
  actions                 = concat(local.read_repos, local.write_repos)
  key_vault_id            = module.akv_devops_squad.id
  token_expiry            = "2024-03-22T17:57:36+08:00"
}


#### Reader Scope ####

module "acr_scope_map_devops_reader" {
  source                  = "../modules/acr-scopes"
  scope_map_name          = "devops-squad-reader"
  container_registry_name = data.terraform_remote_state.azr-shared-services.outputs.acr_shared_name
  resource_group_name     = data.terraform_remote_state.azr-shared-services.outputs.rg_shared_name
  actions                 = local.read_repos
  key_vault_id            = module.akv_devops_squad.id
  token_expiry            = "2024-03-22T17:57:36+08:00"
}