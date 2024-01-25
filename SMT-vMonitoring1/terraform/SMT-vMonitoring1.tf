
# ==== Proxmox Server Info ====
variable "proxmox_node" {
  type = string
}

# ==== VM Info ====
variable "vm_template" {
  type = string
}

variable "vmid" {
  type = number
  default = 300
}

# ==== User Info ====
variable "vm_user" {
  type = string
}



# ----------------------------------------------------------------
# = VM: HL-vMonitoring1
# = Purpose: Docker Host for monitoring stack
# ----------------------------------------------------------------
resource "proxmox_vm_qemu" "SMT-vMonitoring1" {
  # VM Template to clone
  clone = var.vm_template
  full_clone = true

  # VM Info
  vmid        = var.vmid
  name        = "SMT-vMonitoring1"
  desc        = "Monitoring Stack | Grafana | Prometheus | Loki | InfluxDB"
  target_node = var.proxmox_node
  qemu_os     = "l26"

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
  # Code for version 2.10.0 
  # Comment since there is a bug and reverting back to 2.9.16
  # disks {
  #   scsi {
  #     scsi0 {
  #       disk {
  #         size = 5
  #         storage = "local-lvm"
  #         iothread = true
  #       }
  #     }
  #     scsi1 {
  #       disk {
  #         size     = 16
  #         storage  = "local-lvm"
  #         iothread = true
  #       }
  #     }
  #   }
  # }

  #scsi 0 boot drive
  # Disk name and storage need to be forced 
  # Otherwise the vm may end without the OS Disk
  disk {
      type     = "scsi"
      size     = "5G"
      storage  = "local-lvm"
      iothread = 1
      file     = "vm-${var.vmid}-disk-0"
      volume   = "local-lvm:vm-${var.vmid}-disk-0"
  }

  #scsi 1 data drive
  disk {
      type     = "scsi"
      size     = "16G"
      storage  = "local-lvm"
      iothread = 1
  }

  # VM Network
  network {
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = "54:52:00:11:00:00"
  }

  # VM Cloud Init
  os_type    = "cloud-init"
  ipconfig0  = "ip=dhcp"
  ciuser     = var.vm_user
  cipassword = data.hcp_vault_secrets_app.Homelab.secrets["VM_PASSWORD"]
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
      "sudo nmcli connection add type vlan con-name eth0.100 ifname eth0.100 vlan.parent eth0 vlan.id 100 ip4 10.100.100.20/24"
    ]
  }

  # Set the hostname and upgrade the system
  provisioner "remote-exec" {
    inline = [
      "sudo echo '${lower(self.name)}.servers.jndvasco.pt' | sudo tee /etc/hostname",
      "sudo systemd-machine-id-setup",
      "sudo dnf upgrade -y",
      "sudo dnf install cockpit -y",
      "sudo systemctl enable --now cockpit.socket",
    ]
  }

  # Mount extra disk for docker data
  provisioner "remote-exec" {
    inline = [ 
      "sudo mkdir /mnt/data",
      "sudo mkfs.ext4 /dev/sdb",
      "UUID=`sudo blkid /dev/sdb | awk -F ' ' '{print $2}' | sed 's/\"//g'`", # Get the UUID, split on spaces print the second col and remove the "
      "sudo echo \"$UUID\" /mnt/data auto noauto,nofail 0 0 | sudo tee -a /etc/fstab"
     ]  
    
  }

  # Install Docker
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "sudo usermod -aG docker ${var.vm_user}",
      "sudo systemctl enable --now docker",
      "sudo docker network create mainNetwork"
    ]
  }

  # Install Telegraf
  provisioner "remote-exec" {
    script = "../../scripts/telegraf-install-redhat.sh"
  } 

  # reboot the system
  provisioner "remote-exec" {
    inline = [
      "sudo reboot"
    ]
  }
}
