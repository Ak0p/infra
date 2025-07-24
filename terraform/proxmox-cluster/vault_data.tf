data "vault_generic_secret" "pm_creds" {
  path = "proxmox/creds"
}

data "vault_generic_secret" "coreos1_creds" {
  path = "proxmox/coreos"
}

