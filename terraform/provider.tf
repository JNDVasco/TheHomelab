terraform {
  required_providers {
    proxmox = {
      source  = "TheGameProfi/proxmox"
      version = "2.9.16"
      # version = "2.10.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.80.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

# ==== HCP Auth Info ====
variable "HCP_client_id" {
  type = string
}

variable "HCP_client_secret" {
  type = string
}

provider "hcp" {
  client_id     = var.HCP_client_id
  client_secret = var.HCP_client_secret
}

data "hcp_vault_secrets_app" "Homelab" {
  app_name = "Homelab"
}

# ==== Proxmox Auth Info ====
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = data.hcp_vault_secrets_app.Homelab.secrets["HL_SMT_PVE1_TOKEN"]
  pm_tls_insecure     = true
}

# ==== Cloudflare Info ====
variable "cloudflare_domain" {
  type = string
}

provider "cloudflare" {
  api_token = data.hcp_vault_secrets_app.Homelab.secrets["CF_API_TOKEN"]
}
