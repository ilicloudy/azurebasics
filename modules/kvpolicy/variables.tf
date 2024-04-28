#key permissions to be used in Policy
variable "keypermissionspolicy" {
  type = list
  description ="Key Permissions for Service Principal"
  default = ["Get"]
}
#secret permissions to be used in Policy
variable "secretpremissionspolicy" {
  type = list
  description ="Secret Permissions Policy for Service Principal"
  default = ["Get"]
}
#following variables are defined in other modules
variable "keyvaultid" {}
variable "tenant_id" {}
variable "object_id" {}