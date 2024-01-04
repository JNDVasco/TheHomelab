
# ----------------------------------------------------------------
# = VM: HL-vMonitoring1
# = Purpose: Docker Host for various stuff
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

  provisioner "remote-exec" {
    script = "./scripts/telegraf-install-redhat.sh"    
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo echo '${lower(self.name)}.internal.jndvasco.pt' | sudo tee /etc/hostname",
      "sudo systemd-machine-id-setup",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "sudo usermod -aG docker ${var.vm_user}",
      "sudo systemctl enable --now docker",
      "sudo dnf upgrade -y"
    ]
  }
}
