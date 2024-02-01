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

# ==== VM Info ====
variable "vm-def" {
  type = object({
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
  })
}

# ==== Cloudflare Info ====
variable "cf-zone-id" {
  type      = string
  sensitive = true
}


resource "proxmox_vm_qemu" "Fedora39-VM" {
  # VM Template to clone
  clone      = "Fedora39-Cloud"
  full_clone = true

  # VM Info
  target_node = var.vm-def.proxmox-node
  name        = var.vm-def.name
  vmid        = var.vm-def.vmid
  qemu_os     = "l26"

  # VM Misc Settings
  onboot = true
  agent  = 1

  # VM Hardware Specs
  cores   = var.vm-def.cores
  sockets = 1
  cpu     = "host"
  memory  = var.vm-def.memory
  scsihw  = "virtio-scsi-single"

  #scsi 0 boot drive
  # Disk name and storage need to be forced 
  # Otherwise the vm may end without the OS Disk
  disk {
    type     = "scsi"
    size     = "5G"
    storage  = "local-lvm"
    iothread = 1
    file     = "vm-${var.vm-def.vmid}-disk-0"
    volume   = "local-lvm:vm-${var.vm-def.vmid}-disk-0"
  }

  # VM Network
  network {
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = var.vm-def.macaddr
  }

  # VM Cloud Init
  os_type    = "cloud-init"
  ipconfig0  = "gw=${var.vm-def.gw},ip=${var.vm-def.ip}/24"
  ciuser     = var.vm-def.ciuser
  cipassword = var.vm-def.cipassword
  sshkeys    = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9kVnJCnneCB1PpkE+lmWwYy9ilMn1F5YuxXHQ5E/0oxrqjF90xeIGmfWJWHBQPHMeySWC3CgotqpsSTxKoK0dndtgwalZQfxcRXNus0344q3uBTiGT2VIfk3dqKQLTf+XyuM6qO1JHe16SQQyMfcpy4QiiwvSWjrwTXixcY5WNISzBLTDsmzgA7IWVKvY3yjT+rMNnrBNlhcR53gK16sayl6jNDzzfJ1xE6W70WN4zNcPmwoG4ydn1qOhGG8x5rR/vx8Kaan4rOfRS/fcx0T5BRtfz3KE5N0VmIEqUGoSlrGnpmuzlcirt5mhVtDMzUh4c2nTVclC/zL5f0BFB4SdQZyayof0N2ZhBKo2m7gXzml1uc+duoypQRQoUhPjOox+6lsFTVu++8hOcjZ4qMrgOc8ARN4cWix/Bb01T9AHZQIeIycrN1ytfMJ4mzOjHFYWxbHY0hjeV3CMBHAxz2YpzplLV6LFBicJoSoPLt54mLWwySJCYvDp8nxpJ8NeL9M= jndvasco@JNDV-PTT
  EOF

  connection {
    type        = "ssh"
    host        = self.default_ipv4_address
    user        = var.vm-def.ciuser
    private_key = file("/home/jndvasco/.ssh/homelab.key")
  }

  # Set the hostname and upgrade the system
  provisioner "remote-exec" {
    inline = [
      "sudo echo '${lower(var.vm-def.name)}.servers.jndvasco.pt' | sudo tee /etc/hostname",
      "sudo systemd-machine-id-setup",
      "sudo dnf upgrade -y",
      "sudo dnf install git -y",
      "sudo dnf install cockpit -y",
      "sudo systemctl enable --now cockpit.socket",
      "sudo reboot"
    ]
  }
}


resource "cloudflare_record" "DNS-VM" {
  zone_id = var.cf-zone-id
  name    = "${lower(var.vm-def.name)}.servers."
  value   = var.vm-def.ip
  type    = "A"
  proxied = false
  ttl     = 1
}
