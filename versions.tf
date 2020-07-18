terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    resource_group_name  = "az-devops-terraform-rg"
    storage_account_name = "aztfbackend"
    container_name       = "terraform"
    key                  = "terraform-getting-started.tfstate"
  }
}
