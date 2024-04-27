variable "location" {
  type        = string
  description = "Location where the whole deployment is going to take place"
  default     = "westeurope"
}

variable "rgname" {
  type        = string
  description = "Resource group name"
  default     = "rg-azure-bastion"
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
