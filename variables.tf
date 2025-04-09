variable "auth_url" {}
variable "region" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "public_key_path" {
  description = "Chemin vers ta clé publique SSH"
  default     = "~/.ssh/id_rsa.pub"
}
variable "image_name" {
  description = "Nom de l'image (ex: Debian 12)"
}
variable "flavor_name" {
  description = "Nom du flavor (ex: a1-ram1-disk10-perf1)"
}
