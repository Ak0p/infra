resource "proxmox_virtual_environment_acme_dns_plugin" "cloudflare" {
 plugin = "cloudflare" 
 api = "cloudflare"

 data = {
   "CF_ACCOUNT_ID" = 
   "CF_TOKEN" = 
 }
}