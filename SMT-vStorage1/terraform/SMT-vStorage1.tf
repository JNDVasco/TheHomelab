
# ==== Proxmox Server Info ====
variable "proxmox_node" {
  type = string
}




# ----------------------------------------------------------------
# = VM: SMT-vStorage1
# = Purpose: Storage Host
# ----------------------------------------------------------------
resource "proxmox_lxc" "SMT-vStorage1" {
  target_node  = var.proxmox_node
  hostname     = "SMT-vStorage1"
  ostemplate   = "local:vztmpl/almalinux-9-default_20221108_amd64.tar.xz"
  unprivileged = true
  ostype       = "centos"
  vmid         = 118
  start        = true

  cores  = 2
  memory = 512
  swap   = 512

  ssh_public_keys = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9kVnJCnneCB1PpkE+lmWwYy9ilMn1F5YuxXHQ5E/0oxrqjF90xeIGmfWJWHBQPHMeySWC3CgotqpsSTxKoK0dndtgwalZQfxcRXNus0344q3uBTiGT2VIfk3dqKQLTf+XyuM6qO1JHe16SQQyMfcpy4QiiwvSWjrwTXixcY5WNISzBLTDsmzgA7IWVKvY3yjT+rMNnrBNlhcR53gK16sayl6jNDzzfJ1xE6W70WN4zNcPmwoG4ydn1qOhGG8x5rR/vx8Kaan4rOfRS/fcx0T5BRtfz3KE5N0VmIEqUGoSlrGnpmuzlcirt5mhVtDMzUh4c2nTVclC/zL5f0BFB4SdQZyayof0N2ZhBKo2m7gXzml1uc+duoypQRQoUhPjOox+6lsFTVu++8hOcjZ4qMrgOc8ARN4cWix/Bb01T9AHZQIeIycrN1ytfMJ4mzOjHFYWxbHY0hjeV3CMBHAxz2YpzplLV6LFBicJoSoPLt54mLWwySJCYvDp8nxpJ8NeL9M= jndvasco@JNDV-PTT
  EOT

  password = "password"
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  // Storage Backed Mount Point
  mountpoint {
    key     = "0"
    slot    = 0
    storage = "local-lvm"
    mp      = "/mnt/Fast_64GB"
    size    = "64G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.100.1.18/24"
    gw     = "10.100.1.1"
    ip6    = "dhcp"
  }
}
