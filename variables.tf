variable "hcloud_apikey" {}
variable "instance_type" {}
variable "location" {}
variable "coder_domain" {}
variable "acme_email" {}

variable "coder_version" {
  default = "v0.13.1"
}

variable "pg_version" {
  default = "14.2"
}

variable "caddy_version" {
  default = "2.6.2"
}
