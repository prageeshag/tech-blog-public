# locals {
#     prefix-shared       = "shared-services"
#     shared-location       = "eastus"
#     shared-resource-group = "rg-shared-services"
# }


# module "rg_shared_services" {
#   source  = "../modules/rg"
#   name = local.shared-resource-group
#   location = local.shared-location
# }


# module "acr_shared" {
#   source  = "../modules/acr"
#   name =  "prageeshaTechBlog"
#   location = local.shared-location  
#   resource_group = module.rg_shared_services.name
# }

