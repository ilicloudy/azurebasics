variable "location" {
  type        = string
  description = "Location where the whole deployment is going to take place"
  default     = "westeurope"
  validation {
    condition     = can(regex("^(westeurope|uksouth)$", var.location))
    error_message = "Resources can only be provisioned in two regions West Europe and UKSouth"
  }
}

variable "rgname" {
  type        = string
  description = "Resource group name for bastion"
  default     = "rg-azure-bastion"
}

variable "rgvault" {
  type        = string
  description = "Resource group name of vault"
  default     = "rg-azkeyvault"
}

variable "vnetname" {
  type        = string
  description = "vnet name"
  default     = "vnetbastion"
}

variable "addressspace" {
  type        = list(any)
  description = "Address Space for VNET"
  default     = ["192.168.0.0/25"]
}

variable "azbastionsubnet" {
  type        = list(any)
  description = "Address Space for VNET"
  default     = ["192.168.0.0/26"]
}

variable "serversubnet" {
  type        = list(any)
  description = "Address Space for VNET"
  default     = ["192.168.64.0/27"]
}

variable "keyvaultname" {
  type        = string
  description = "az key vault name"
  default     = "keyvaul"
}

variable "pwd" {
  type        = string
  description = " pwd of vm"

}

variable "useradmin" {
  type        = string
  description = " admin of vm"

}

variable "tenant_id" {
  type        = string
  description = "id of tenant"
}


variable "object_id" {
  type        = string
  description = "id of object"
}

variable "appname" {}