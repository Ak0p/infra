data "local_file" "ssh_public_key" {
  filename = "homesrv.pub"
}

data "ct_config" "coreos1_vm_ignition" {
  strict = true
  content = templatefile("butane/coreos1.yml.tftpl", {
    ssh_admin_username   = data.vault_generic_secret.coreos1_creds.data["user"]
    ssh_admin_public_key = data.local_file.ssh_public_key.content
    hostname             = "nobla"
    password_hash        = base64encode(data.vault_generic_secret.coreos1_creds.data["passwd"])
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

  disk {
    interface   = "virtio0"
    import_from = "lvm-pv-uuid-Dcm2b3-CBMm-5v8Z-hLdB-xG0R-YDsA-lI9tp9"
  }

  network_device {
    bridge = "vmbr0"
  }

  # initialization {
  #   user_data_file_id = "local:snippets/coreos-ignition.ign"
  # }



  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.coreos1_vm_ignition.rendered, ",", ",,")}'"

}

# resource "proxmox_virtual_environment_file" "coreos1_ignition_file" {

#   depends_on     = [data.ct_config.coreos1_vm_ignition]
#   content_type   = "snippets"
#   datastore_id   = "local"
#   node_name      = "proxmox1"
#   timeout_upload = 70
#   # file_mode    = "0700"


#   source_raw {
#     data      = <<-EOF
#     ${data.ct_config.coreos1_vm_ignition.rendered}
#     EOF
#     file_name = "coreos-ignition.ign"
#   }

# }

# Home Asissant VM
resource "proxmox_virtual_environment_vm" "haos16" {
  name            = "haos16"
  description     = "Managed by Terraform"
  tags            = ["terraform"]
  stop_on_destroy = false


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


# resource "proxmox_virtual_environment_download_file" "fedora-coreos-42" {

#   content_type            = "import"
#   datastore_id            = "local"
#   node_name               = "proxmox1"
#   url                     = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/42.20250623.3.1/x86_64/fedora-coreos-42.20250623.3.1-qemu.x86_64.qcow2.xz"
#   file_name               = "fedora-coreos-42.20250623.3.1-qemu.x86_64.qcow2"
#   decompression_algorithm = "gz"
#   checksum                = "sha256:a3176646ea2bd53d2905f7af9537938038a32d49a7e318abc3a9e3ed1ea1e0b3"
#   checksum_algorithm      = "sha256"

# }


# resource "proxmox_virtual_environment_download_file" "haos-16_0-image" {

#   content_type            = "import"
#   datastore_id            = "local"
#   node_name               = "proxmox1"
#   url                     = "https://github.com/home-assistant/operating-system/releases/download/16.0/haos_ova-16.0.qcow2.xz"
#   file_name               = "haos_ova-16.0.qcow2"
#   decompression_algorithm = "gz"
#   checksum                = "sha256:24c5f30619da5ad8534d615023626361783c7436b67c06afe53b58a4ff6cd6b5"
#   checksum_algorithm      = "sha256"

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
