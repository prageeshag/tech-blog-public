output "object" {
  value = azurerm_container_registry.acr
  description = "returns the full Azure Key Vault Object"
}

output "name" {
  value = azurerm_container_registry.acr.name
}

output "id" {
  value = azurerm_container_registry.acr.id
}
