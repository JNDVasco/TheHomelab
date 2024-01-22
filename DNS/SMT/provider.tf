terraform {
    required_version = ">= 1.0.0"
    required_providers {
      cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "0.80.0"
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


# ==== Cloudflare Info ====
variable "cloudflare_domain" {
    type = string
}

provider "cloudflare" {
  api_token = data.hcp_vault_secrets_app.Homelab.secrets["CF_API_TOKEN"]
}
