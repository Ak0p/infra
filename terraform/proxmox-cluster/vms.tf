data "local_file" "ssh_public_key" {
  filename = "homesrv.pub"
}

# VM Setup

# Container Host VM

resource "proxmox_virtual_environment_vm" "coreos1" {
  name        = "coreos1"
  description = "Docker host VM"
  tags        = ["terraform"]

  node_name = "proxmox1"
  vm_id     = 102

  stop_on_destroy = true

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
    size         = 100
  }

  network_device {
    bridge = "vmbr0"
  }


  initialization {
    user_account {
      username = "valen"
      password = random_password.haos_vm_pass.result
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }

  }

}

# Home Asissant VM
resource "proxmox_virtual_environment_vm" "haos16" {
  name            = "haos16"
  description     = "Managed by Terraform"
  tags            = ["terraform"]
  stop_on_destroy = false


  node_name = "proxmox1"
  vm_id     = 101


  bios = "ovmf"

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


# output "haos_vm_public_key" {
#   value = tls_private_key.haos_vm_key.public_key_openssh
# }
