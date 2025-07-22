variable "vault_token" {
  description = "Hashicorp vault token"
  type        = string
  sensitive   = true
  # default     = "
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.1.112:8006/api2/json"
}

variable "pm_user" {
  description = "Proxmox username"
  type        = string
  default     = "root@pam"
}

# variable "pm_password" {
#   description = "Proxmox password"
#   type        = string
#   sensitive   = true
# }

variable "pm_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "storage" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vmid" {
  description = "VM ID (leave null for auto-assignment)"
  type        = number
  default     = null
}

variable "haos_version" {
  description = "Home Assistant OS version (stable, beta, dev)"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta", "dev"], var.haos_version)
    error_message = "HAOS version must be one of: stable, beta, dev"
  }
}
