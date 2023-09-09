data "terraform_remote_state" "azr-shared-services" {
  backend = "azurerm"
  config = {
    storage_account_name = "prageeshatfstate"
    container_name       = "tf-state"
    key                  = "shared-services-terraform.tfstate"
    access_key = var.az_storage_account_access_key
  }
}

