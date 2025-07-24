terraform {

  required_version = "~> 1.12.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }

  }
}

provider "proxmox" {
  endpoint = var.pm_api_url
  # api_token = "root@pam!terraform2=${data.vault_generic_secret.pm_creds.data["pm_api_token"]}"
  insecure = true
  username = "root@pam"
  password = data.vault_generic_secret.pm_creds.data["pm_passwd"]

  ssh {
    agent    = true
    username = "root"
    password = data.vault_generic_secret.pm_creds.data["pm_passwd"]
  }


}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}



