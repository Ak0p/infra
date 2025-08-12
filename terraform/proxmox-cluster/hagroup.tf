resource "proxmox_virtual_environment_hagroup" "home" {
  group   = "home"
  comment = "Managed by Terraform"

  nodes = {
    "proxmox1" : 1
    "proxmox2" : 1
  }
}
