# 1. Terraform & Provider Configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# 3. Azure SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project_name}-${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

# 4. Azure SQL Database (Serverless Free-Tier Compatible)
resource "azurerm_mssql_database" "db" {
  name      = "db-${var.project_name}"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "GP_S_Gen5_1" 
  
  # FIX: Azure requires a minimum of 0.5 vCores for Serverless
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
}

# 5. Allow Azure services (like our App Service) to connect
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# 6. App Service Plan (Using B1 to bypass F1 Quota restrictions)
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  # Switch back to Linux (it's better for .NET 8 containers later)
  os_type             = "Linux" 
  sku_name            = "B1" # This uses your $200 credits!
}

# 7. Linux Web App (Updated to match Linux Plan)
resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}


# Create the Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrcleancodefrancisco456789"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Output the Login Server URL so we know where to push
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

