variable "vm-defs" {
  type = list(object({
    proxmox-node = string
    name         = string
    vmid         = number
    cores        = number
    memory       = number
    macaddr      = string
    ip           = string
    gw           = string
    ciuser       = string
    cipassword   = string
  }))
}

module "Fedora39-VM" {
  source     = "./modules"
  cf-zone-id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]
  for_each   = { for each in var.vm-defs : each.name => each }
  vm-def     = each.value
}
