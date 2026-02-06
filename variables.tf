variable "location" {
  description = "Azure region to deploy resources (e.g., westeurope, eastus)"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "minecraft-rg"
}

variable "storage_account_name" {
  description = "Name of the Storage Account (must be globally unique)"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
}

variable "image_name" {
  description = "Container image to deploy (e.g., usually itzg/minecraft-server, but we will proxy it)"
  type        = string
  default     = "itzg/minecraft-server:stable-java21-jdk"
}

variable "domain_name" {
  description = "The custom domain name to manage in Azure DNS (e.g., mydomain.com). If null, uses default ACA FQDN."
  type        = string
  default     = null
}

variable "container_app_name" {
  description = "Name of the Minecraft Container App"
  type        = string
  default     = "minecraft-app"
}

variable "aca_environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
  default     = "minecraft-env"
}
