# resource "proxmox_virtual_environment_container" "wireguard_lxc" {

#   depends_on = [proxmox_virtual_environment_download_file.alpine_image]

#   description = "Managed by Terraform"
#   tags        = ["terraform"]

#   node_name = "proxmox2"
#   vm_id     = 201

#   operating_system {
#     template_file_id = proxmox_virtual_environment_download_file.alpine_image.id
#     type             = "alpine"
#   }

#   network_interface {
#     bridge  = "vmbr0"
#     enabled = true
#     name    = "veth0"

#   }

#   cpu {
#     cores = 1
#   }

#   memory {
#     dedicated = 256
#   }

#   disk {
#     datastore_id = "local-lvm"
#     size         = 2
#   }

#   initialization {
#     hostname = "adguard"
#     user_account {
#       password = random_password.wireguard_pass.result
#       keys     = [trimspace(data.local_file.ssh_public_key.content)]
#     }

#     ip_config {
#       ipv4 {
#         address = "192.168.1.2"
#         gateway = "192.168.1.1"
#       }
#     }


#   }
# }

# resource "random_password" "adguard_pass" {
#   length           = 16
#   override_special = "_%@"
#   special          = true
# }


# resource "proxmox_virtual_environment_download_file" "alpine_image" {
#   datastore_id = "local"
#   content_type = "vztmpl"
#   node_name    = "proxmox2"
#   url          = "http://download.proxmox.com/images/system/alpine-3.22-default_20250617_amd64.tar.xz"
# }

# output "wireguard_ip" {
#   depends_on = [proxmox_virtual_environment_container.wireguard_lxc]
#   value      = proxmox_virtual_environment_container.wireguard_lxc.ipv4
# }

# # output "wireguard_pass" {
# #   value     = random_password.wireguard_pass.result
# #   sensitive = true
# # }

# resource "vault_kv_secret_v2" "adguard_password" {
#   mount = "proxmox"
#   name  = "lxc/adguard/"

#   data_json = jsonencode({
#     password = random_password.wireguard_pass.result
#   })


# }

# resource "proxmox_virtual_environment_haresource" "wireguard_lxc" {
#   depends_on = [proxmox_virtual_environment_hagroup.home]

#   resource_id = "ct:${proxmox_virtual_environment_container.wireguard_lxc.id}"
#   group       = proxmox_virtual_environment_hagroup.home.id
#   state       = "started"
#   comment     = "Managed by Terraform"

# }


