# TheHomelab

The last homelab revision before I decide this one isn't good enough and make another last revision.
Hopefully this time with less hardcode and leaked credentials

## Main Highlights
- Credential and secret managed by [HCP Vault Secrets](https://developer.hashicorp.com/hcp/docs/vault-secrets)
- Focus even more on reproducibility i.e more focus on Infrastructure as Code with [Terraform](https://www.terraform.io/) and automation with scrips and [Ansible](https://www.ansible.com/)



## Hardware
Currently I have two homelabs in two different locations.

### SMT

| Hostname |      OS     |        Specs        |   Storage   |
|:--------:|:-----------:|:-------------------:|:-----------:|
| SMT-PVE1 | Proxmox 8.1 | i5-7500 \| 24GB RAM | 1x512GB SDD |
| SMT-PVE2 | Proxmox 8.1 | i5-7500 \| 24GB RAM | 1x512GB SDD |

These two proxmox hosts are configured as a proxmox cluster. The configuration has been changed so that if one node goes down it is no locked due to the lack of quorum votes.


### Main Lab

|  Hostname  |      OS     |         Specs        |                  Storage                  |
|:----------:|:-----------:|:--------------------:|:-----------------------------------------:|
|   HL-PVE1  | Proxmox 8.1 | i7-11700 \| 64GB RAM | 2x 512GB NVMe \| 1x3TB HDD \| 1x512GB SDD |
| HL-Docker1 |  Fedora 39  |       RPi 4 2GB      |             64GB Micro SD Card            |
|    NAS3    |     QTS     |   J1900 \| 16GB RAM  |            4x16TB HDD @ RAID 1            |