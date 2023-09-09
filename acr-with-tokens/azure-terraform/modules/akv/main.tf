
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "akv" {

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = false
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false

  sku_name = "standard"

  # Create access policies
  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      object_id          = access_policy.value.object_id
      tenant_id          = access_policy.value.tenant_id
      secret_permissions = access_policy.value.secret_permissions
      key_permissions = access_policy.value.key_permissions
      storage_permissions = access_policy.value.storage_permissions
    }
  } 
}