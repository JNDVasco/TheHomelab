vm-defs = [
  {
    proxmox-node = "smt-pve1"
    name         = "SMT-vMonitoring1"
    subdomain       = "servers"
    vmid         = 400
    cores        = 2
    memory       = 4096
    macaddr      = "54:52:00:10:03:00"
    ip           = "10.100.1.30"
    gw           = "10.100.1.1"
    ciuser       = "jndvasco"
  },
  {
    proxmox-node = "smt-pve1"
    name         = "SMT-vWazuh1"
    subdomain       = "servers"
    vmid         = 401
    cores        = 2
    memory       = 2048
    macaddr      = "54:52:00:10:03:01"
    ip           = "10.100.1.31"
    gw           = "10.100.1.1"
    ciuser       = "jndvasco"
  },
  {
    proxmox-node = "smt-pve1"
    name         = "SMT-vDocker1"
    subdomain       = "servers"
    vmid         = 402
    cores        = 2
    memory       = 2048
    macaddr      = "54:52:00:10:03:02"
    ip           = "10.100.1.32"
    gw           = "10.100.1.1"
    ciuser       = "jndvasco"
  },
  {
    proxmox-node = "smt-pve3"
    name         = "SMT-vMedia1"
    subdomain       = "servers"
    vmid         = 403
    cores        = 2
    memory       = 2048
    macaddr      = "54:52:00:10:03:03"
    ip           = "10.100.1.33"
    gw           = "10.100.1.1"
    ciuser       = "jndvasco"
  } 
]
