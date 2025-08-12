data "local_file" "ssh_public_key" {
  filename = "homesrv.pub"
}

data "external" "yescrypt_hash" {
  program = ["bash", "-c", "echo '{\"hash\":\"'$(mkpasswd -m yescrypt \"${data.vault_generic_secret.coreos1_creds.data["passwd"]}\")'\"}'"]
}

data "ct_config" "coreos1_vm_ignition" {
  strict = true
  content = templatefile("butane/coreos1.yml.tftpl", {
    ssh_admin_username   = data.vault_generic_secret.coreos1_creds.data["user"]
    ssh_admin_public_key = data.local_file.ssh_public_key.content
    hostname             = "nobla"
    password_hash        = data.external.yescrypt_hash.result.hash
  })
}

# VM Setup

# Container Host VM

resource "proxmox_virtual_environment_vm" "coreos1" {

  name        = "coreos1"
  description = "Docker host VM"
  tags        = ["terraform"]

  node_name = "proxmox1"
  vm_id     = 102
  machine   = "q35"

  stop_on_destroy = true

  agent {
    enabled = true
  }
  cpu {
    cores = 8
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = "local:import/fedora-coreos-42.qemu.qcow2"
    interface    = "scsi0"
    size         = 200
  }

  network_device {
    bridge = "vmbr0"
  }

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.coreos1_vm_ignition.rendered, ",", ",,")}'"

}


# Home Asissant VM
resource "proxmox_virtual_environment_vm" "haos16" {
  name            = "haos16"
  description     = "Managed by Terraform"
  tags            = ["terraform"]
  stop_on_destroy = true


  node_name = "proxmox1"
  vm_id     = 101




  bios = "ovmf"

  agent {
    enabled = true
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = "local:import/haos_ova-16.0.qcow2"
    interface    = "virtio0"
    size         = "32"
  }

  network_device {
    bridge = "vmbr0"
  }


  initialization {
    user_account {
      username = "root"
      password = random_password.haos_vm_pass.result
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }
}




# TrueNAS SCALE

# resource "proxmox_virtual_environment_vm" "truenas" {
#   name            = "truenas"
#   description     = "Managed by Terraform"
#   tags            = ["terraform"]
#   stop_on_destroy = false


#   node_name = "proxmox1"
#   vm_id     = 103


#   bios = "ovmf"
#   efi_disk {
#     datastore_id = "local-lvm"
#     type         = "4m"
#   }

#   cdrom {
#     file_id = proxmox_virtual_environment_download_file.truenas-SCALE-25-04-2-image.id
#   }

#   agent {
#     enabled = true
#   }


#   cpu {
#     cores = 4
#     type  = "x86-64-v2-AES"
#   }

#   memory {
#     dedicated = 8192
#     floating  = 8192
#   }

#   disk {
#     datastore_id = "local-lvm"
#     interface    = "virtio0"
#     size         = "32"
#     import_from  = proxmox_virtual_environment_download_file.truenas-SCALE-25-04-2-image.id
#   }

#   network_device {
#     bridge = "vmbr0"
#   }


#   initialization {
#     user_account {
#       username = "root"
#       password = random_password.haos_vm_pass.result
#       keys     = [trimspace(data.local_file.ssh_public_key.content)]
#     }
#   }
# }


# resource "proxmox_virtual_environment_download_file" "truenas-SCALE-25-04-2-image" {

#   content_type       = "iso"
#   datastore_id       = "local"
#   node_name          = "proxmox1"
#   url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.2/TrueNAS-SCALE-25.04.2.iso"
#   file_name          = "TrueNAS-SCALE-25.04.2.iso"
#   checksum           = "248635f8b2f91eebf88d37911ad934df99d1c2f5675c76caef5c86a76a2532c4"
#   checksum_algorithm = "sha256"

# }

resource "random_password" "haos_vm_pass" {
  length           = 16
  override_special = "_%@"
  special          = true
}

output "haos_vm_pass" {
  value     = random_password.haos_vm_pass.result
  sensitive = true
}

output "debug_ignition_config" {
  value = data.ct_config.coreos1_vm_ignition.rendered
  # sensitive = true # Since it contains credentials
}

# output "haos_vm_public_key" {
#   value = tls_private_key.haos_vm_key.public_key_openssh
# }


resource "proxmox_virtual_environment_haresource" "haos_vm" {
  depends_on = [proxmox_virtual_environment_hagroup.home]

  resource_id = "vm:${proxmox_virtual_environment_vm.haos16.id}"
  group       = proxmox_virtual_environment_hagroup.home.id
  state       = "started"
  comment     = "Managed by Terraform"

}

