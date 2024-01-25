# ----------------------------------------------------------------
#   Main DNS
# ----------------------------------------------------------------

# ---------------------------------------------------------------
# = DNS Entry: jndvasco.pt
# = Purpose: Main DNS, currently managed by a DDNS provider
# ---------------------------------------------------------------
# resource "cloudflare_record" "main" {
#   zone_id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]
#   name    = "@"
#   value   = "10.10.10.10"
#   type    = "A"
#   proxied = true
#   ttl     = 1
# }

# ----------------------------------------------------------------
#   General Homelab DNS 
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# = DNS Entry: *.smt.jndvasco.pt
# = Purpose: All services on the homelab are proxied on this 
#            machine, under this domain (internal access only)
# ----------------------------------------------------------------
# resource "cloudflare_record" "lab" {
#   zone_id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]y
#   name    = "*.lab"
#   value   = 
#   type    = "A"
#   proxied = false
#   ttl     = 1
# }

# ----------------------------------------------------------------
# = DNS Entry: smt-pve1.servers.jndvasco.pt
# = Purpose: 
# ----------------------------------------------------------------
resource "cloudflare_record" "smt-pve1" {
  zone_id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]
  name    = "smt-pve1.servers."
  value   = "10.100.1.11"
  type    = "A"
  proxied = false
  ttl     = 1
}

# ----------------------------------------------------------------
# = DNS Entry: smt-pve2.servers.jndvasco.pt
# = Purpose: 
# ----------------------------------------------------------------
resource "cloudflare_record" "smt-pve2" {
  zone_id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]
  name    = "smt-pve2.servers."
  value   = "10.100.1.12"
  type    = "A"
  proxied = false
  ttl     = 1
}

# ----------------------------------------------------------------
# = DNS Entry: smt-pve3.servers.jndvasco.pt
# = Purpose: 
# ----------------------------------------------------------------
resource "cloudflare_record" "smt-pve3" {
  zone_id = data.hcp_vault_secrets_app.Homelab.secrets["CF_ZONE_ID"]
  name    = "smt-pve3.servers."
  value   = "10.100.1.13"
  type    = "A"
  proxied = false
  ttl     = 1
}
