variable "key" {
    type = string
    description = "My key for VM"
    default = "user"
}

variable "secret" {
    type = string
    description = "Secret value"
    default ="pwd"
}
variable "keyvaultid" {}