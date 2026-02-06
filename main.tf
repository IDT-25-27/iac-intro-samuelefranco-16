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

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# --- Azure Container Registry ---
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# --- Azure DNS Zone ---
resource "azurerm_dns_zone" "dns" {
  count               = var.domain_name != null ? 1 : 0
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

# --- Storage Account & Share ---
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "mc_data" {
  name                 = "mc-data"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}

# --- Container Apps Environment ---
resource "azurerm_log_analytics_workspace" "log" {
  name                = "minecraft-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = var.aca_environment_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
}

# Mount Azure Files to ACA Environment
resource "azurerm_container_app_environment_storage" "mc_share" {
  name                         = "mc-data-mount"
  container_app_environment_id = azurerm_container_app_environment.env.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.mc_data.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadWrite"
}

# --- Container App (Minecraft) ---
resource "azurerm_container_app" "mc" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # Ingress for Minecraft TCP Port
  ingress {
    external_enabled = true
    target_port      = 25565
    exposed_port     = 25565
    transport        = "tcp"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "minecraft-server"
      image  = var.image_name # Currently pulling from Docker Hub. To use ACR, push image there and update reference.
      cpu    = 2.0
      memory = "8Gi"

      env {
        name  = "EULA"
        value = "TRUE"
      }
      env {
        name  = "TYPE"
        value = "MODRINTH"
      }
      env {
        name  = "VERSION"
        value = "1.21.1"
      }
      env {
        name  = "ONLINE_MODE"
        value = "false"
      }
      env {
        name  = "MODRINTH_MODPACK"
        value = "5FFgwNNP"
      }
      env {
        name  = "MODRINTH_VERSION"
        value = "1.7.3"
      }
      env {
        name  = "MEMORY"
        value = "7G" # Java Heap
      }
      env {
        name  = "MOTD"
        value = "CobbleMon ACA"
      }
      env {
        name  = "ICON"
        value = "https://cdn.modrinth.com/data/5FFgwNNP/e7f9ee2e9d361623847853fe2ddce42f519ee64f.png"
      }
      env {
        name  = "USE_AIKAR_FLAGS"
        value = "true"
      }
      env {
        name  = "USE_MEOWICE_FLAGS"
        value = "true"
      }
      env {
        name  = "TZ"
        value = "Europe/Rome"
      }
      env {
        name  = "DIFFICULTY"
        value = "2"
      }
      env {
        name  = "LEVEL"
        value = "devops"
      }
      env {
        name  = "REGION_FILE_COMPRESSION"
        value = "lz4"
      }
      env {
        name  = "MAX_PLAYERS"
        value = "30"
      }
      env {
        name  = "OPS"
        value = "admin"
      }
      env {
        name  = "ENABLE_WHITELIST"
        value = "true"
      }
      env {
        name  = "WHITELIST"
        value = "admin,user"
      }
      env {
        name  = "MODRINTH_PROJECTS"
        value = "uvpymuxq:XWtayRKd"
      }
      env {
        name  = "MODRINTH_DOWNLOAD_DEPENDENCIES"
        value = "required"
      }
      env {
        name  = "ENFORCE_SECURE_PROFILE"
        value = "false"
      }
      env {
        name  = "ALLOW_FLIGHT"
        value = "true"
      }

      # Additional Env vars can be added here...

      volume_mounts {
        name = "data"
        path = "/data"
      }
    }

    volume {
      name         = "data"
      storage_name = azurerm_container_app_environment_storage.mc_share.name
      storage_type = "AzureFile"
    }
  }
}

# --- DNS Record ---
# Point the domain root (@) or a subdomain to the ACA Static IP
# Note: ACA with TCP Ingress exposes a Static IP.
resource "azurerm_dns_a_record" "mc_dns" {
  count               = var.domain_name != null ? 1 : 0
  name                = "@" # Root of the domain, e.g., mydomain.com
  zone_name           = azurerm_dns_zone.dns[0].name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
} # Verify if ingress provides IP for TCP. Yes, Managed Environment consumption profile usually has a static IP.
