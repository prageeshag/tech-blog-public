variable "scope_map_name" {
  description = "Name of the scope map"
  type        = string
}

variable "container_registry_name" {
  description = "Name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "actions" {
  description = "List of actions for the scope map"
  type        = list(string)
}

variable "key_vault_id" {}

variable "token_expiry" {}