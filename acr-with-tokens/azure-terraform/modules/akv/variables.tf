variable "name" {
  default     = ""
}

variable "location" {
  default     = ""
}

variable "resource_group" {
  default     = ""
}

variable "tenant_id" {
  default     = ""
}

variable "access_policies" {
  description = "List of access policies"
  type        = list(object({
    tenant_id          = string
    object_id          = string
    secret_permissions = list(string)
    storage_permissions = list(string)
    key_permissions = list(string)
  }))
}

