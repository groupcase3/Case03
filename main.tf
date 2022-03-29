terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG_ABC_Group03"
  location = "Korea Central"
}
resource "azurerm_app_service_plan" "app-plan" {
  name                = "serviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Premium"
    size = "P1v2"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "group03-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app-plan.id
  source_control {
    repo_url           = "https://github.com/WordPress/WordPress"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

# resource "azurerm_monitor_autoscale_setting" "scale" {
#   name                = "scale"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   target_resource_id  = azurerm_app_service.webapp.id

#   profile {
#     name = "defaultProfile"

#     capacity {
#       default = 1
#       minimum = 1
#       maximum = 10
#     }

#     rule {
#       metric_trigger {
#         metric_name        = "Percentage CPU"
#         metric_resource_id = azurerm_app_service.webapp.id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "GreaterThan"
#         threshold          = 75
#         metric_namespace   = "microsoft.compute/virtualmachinescalesets"
#         dimensions {
#           name     = "AppName"
#           operator = "Equals"
#           values   = ["App1"]
#         }
#       }

#       scale_action {
#         direction = "Increase"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT1M"
#       }
#     }

#     rule {
#       metric_trigger {
#         metric_name        = "Percentage CPU"
#         metric_resource_id = azurerm_app_service.webapp.id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "LessThan"
#         threshold          = 25
#       }

#       scale_action {
#         direction = "Decrease"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT1M"
#       }
#     }
 
#   # notification {
#   #   email {
#   #     send_to_subscription_administrator    = true
#   #     send_to_subscription_co_administrator = true
#   #     custom_emails                         = ["admin@contoso.com"]
#   #   }
#   # }
#   }
# }

resource "azurerm_mysql_server" "mysql-server" {
  name                = "group03-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "group03"
  administrator_login_password = "Linkbynet1397"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
}

resource "azurerm_mysql_database" "app-db" {
  name                = "wpgroup03"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
