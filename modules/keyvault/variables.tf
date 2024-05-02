#key permissions used at creation of vault
variable "keypermissionspolicy" {
  type = list
  description ="Key Permissions for Service Principal"
  default = ["Get"]
}

#secret permissions used at creation of vault
variable "secretpremissionspolicy" {
  type = list
  description ="Secret Permissions Policy for Service Principal"
  default = ["Get"]
}

variable "rgvault" {}
variable "keyvaultname" {}
variable "tenant_id" {}
variable "object_id" {}
variable "location" {}
