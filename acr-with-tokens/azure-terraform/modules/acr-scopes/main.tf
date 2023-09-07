resource "azurerm_container_registry_scope_map" "scope_map" {
  name                    = var.scope_map_name
  container_registry_name = var.container_registry_name
  resource_group_name     = var.resource_group_name
  actions                 = var.actions
}

resource "azurerm_container_registry_token" "token" {
  name                    = var.scope_map_name
  container_registry_name = var.container_registry_name
  resource_group_name     = var.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.scope_map.id
}

resource "azurerm_container_registry_token_password" "token_pwd" {
  container_registry_token_id = azurerm_container_registry_token.token.id
  password1 {
    expiry = var.token_expiry
  }
}

resource "azurerm_key_vault_secret" "secret" {
  name         = var.scope_map_name
  value        = azurerm_container_registry_token_password.token_pwd.password1[0].value
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_container_registry_token_password.token_pwd]
}
