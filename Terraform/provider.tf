terraform {
  required_providers {
    proxmox = {
      source = "TheGameProfi/proxmox"
      version = "2.9.15"
    }
  }
}

# ==== Proxmox Auth Info ====
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret
    pm_tls_insecure = true
}

# ==== Proxmox Server Info ====
variable "proxmox_node" {
  type = string
}

variable "vm_template" {
  type    = string
}

# ==== User Info ====
variable "vm_user" {
  type      = string
  sensitive = true

}

variable "vm_user_password" {
  type      = string
  sensitive = true
}