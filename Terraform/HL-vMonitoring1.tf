
# ==== Proxmox Server Info ====
variable "proxmox_node" {
  type = string
}

variable "vm_template" {
  type = string
}

# ==== User Info ====
variable "vm_user" {
  type = string
}

variable "vm_user_password" {
  type      = string
  sensitive = true
}

# ==== SMB Share Info ====
variable "smb_server" {
  type = string
}

variable "smb_share" {
  type = string
}

variable "smb_user" {
  type = string
}

variable "smb_password" {
  type      = string
  sensitive = true
}


# ----------------------------------------------------------------
# = VM: HL-vMonitoring1
# = Purpose: Docker Host for monitoring stack
# ----------------------------------------------------------------
resource "proxmox_vm_qemu" "HL-vMonitoring1" {
  # VM Template to clone
  clone = var.vm_template

  # VM Info
  vmid        = 303
  name        = "HL-vMonitoring1"
  desc        = "Monitoring Stack | Grafana | Prometheus | Loki | InfluxDB"
  target_node = var.proxmox_node

  # VM Misc Settings
  onboot = true
  agent  = 1

  # VM Hardware Specs
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 4096
  scsihw  = "virtio-scsi-single"

  # VM Disks
  # disk {
  #   size     = "8G"
  #   storage  = "local-lvm"
  #   type     = "virtio"
  #   iothread = 1
  # }

  # VM Network
  network {
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = "54:52:00:00:00:01"
  }

  # VM Cloud Init
  os_type    = "cloud-init"
  ipconfig0  = "ip=dhcp"
  ciuser     = var.vm_user
  cipassword = var.vm_user_password
  sshkeys    = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9kVnJCnneCB1PpkE+lmWwYy9ilMn1F5YuxXHQ5E/0oxrqjF90xeIGmfWJWHBQPHMeySWC3CgotqpsSTxKoK0dndtgwalZQfxcRXNus0344q3uBTiGT2VIfk3dqKQLTf+XyuM6qO1JHe16SQQyMfcpy4QiiwvSWjrwTXixcY5WNISzBLTDsmzgA7IWVKvY3yjT+rMNnrBNlhcR53gK16sayl6jNDzzfJ1xE6W70WN4zNcPmwoG4ydn1qOhGG8x5rR/vx8Kaan4rOfRS/fcx0T5BRtfz3KE5N0VmIEqUGoSlrGnpmuzlcirt5mhVtDMzUh4c2nTVclC/zL5f0BFB4SdQZyayof0N2ZhBKo2m7gXzml1uc+duoypQRQoUhPjOox+6lsFTVu++8hOcjZ4qMrgOc8ARN4cWix/Bb01T9AHZQIeIycrN1ytfMJ4mzOjHFYWxbHY0hjeV3CMBHAxz2YpzplLV6LFBicJoSoPLt54mLWwySJCYvDp8nxpJ8NeL9M= jndvasco@JNDV-PTT
  EOF

  connection {
    type        = "ssh"
    host        = self.default_ipv4_address
    user        = var.vm_user
    private_key = file("/home/jndvasco/.ssh/homelab.key")
  }

  # Network Config
  provisioner "remote-exec" {
    inline = [
      "sudo nmcli connection add type vlan con-name eth0.10 ifname eth0.10 vlan.parent eth0 vlan.id 10 ip4 10.0.10.4/24",
      "sudo nmcli connection add type vlan con-name eth0.20 ifname eth0.20 vlan.parent eth0 vlan.id 20 ip4 10.0.20.4/24"
    ]
  }

  # Mount a SMB Share
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /mnt/${var.smb_share}",
      "sudo mount -t cifs //${var.smb_server}/${var.smb_share} /mnt/${var.smb_share} -o vers=3.0,username=${var.smb_user},password=${var.smb_password},dir_mode=0777,file_mode=0777",
      "touch /mnt/${var.smb_share}/HL-vMonitoring1-OK.txt"
    ]
  }

  # Install Docker
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "sudo usermod -aG docker ${var.vm_user}",
      "sudo systemctl enable --now docker"
    ]
  }

  # Install Telegraf
  provisioner "remote-exec" {
    script = "../scripts/telegraf-install-redhat.sh"
  }

  # Set the hostname and upgrade the system
  provisioner "remote-exec" {
    inline = [
      "sudo echo '${lower(self.name)}.servers.jndvasco.pt' | sudo tee /etc/hostname",
      "sudo systemd-machine-id-setup",
      "sudo dnf upgrade -y"
    ]
  }
}
