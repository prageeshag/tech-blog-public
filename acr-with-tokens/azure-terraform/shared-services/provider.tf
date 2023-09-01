terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.70.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rg-managment"
      storage_account_name = "prageeshatfstate"
      container_name       = "tf-state"
      key                  = "shared-services-terraform.tfstate"
  }

}


provider "azurerm" {
  features {}

  ## Following is the serevice principal for "sp-terraform-provisoner"
  subscription_id   = var.az_subscription_id
  tenant_id         = var.az_tenant_id
  client_id         = var.az_client_id
  client_secret     = var.az_client_secret
}


