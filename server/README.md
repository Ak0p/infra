# Ansible Secure Home Lab
A simple home lab config, heavily inspired from [this repo](https://github.com/notthebee/infra).

This config aims to create a secure self hosted environment by using Cloudflare as an outside reverse proxy and Nginx Proxy Manager as an inside reverse proxy.
   
It uses docker compose to create the containers for the services which are to be hosted on the machine.  
  
The target device is a laptop running Fedora Server.  
  

## Explanation
First you will need to own a domain and transfer the domain to Cloudflare.  
On the Cloudflare dashboard create a new api token and add it to the vault in `group_vars/all/vault.yml` file with the name *`vault_api_token`*.   
  
Inside the `roles/containers/templates/config.json` file will be the CloudflareDDNS config which you are free to change as you like. Remember that the default config will proxy all your traffic and will not expose your public ip address.  
  
After setting up Cloudflare go into the NPM dashboard and create a new certificate with the DNS challenge set to Cloudflare. Here you will need to paste in the provided API token.  
Create a new certificate with domain.com and *.domain.com as the selected domains if you wish to use the same certificate for every subdomain.  

Create a new proxy entry in NPM for every service you need. In this case the containers for the services are on the same network as the NPM container and you can just use the container name as the exposed internal port for the connection to work. Lastly, assign the certificate to every created proxy.  

**For this all to work forwarding port 443 (HTTPS) is needed on the gateway router.**
  

  
## Security

The config uses the builtin ansible vault module to store all sensitive data in `group_vars/all/vault.yml`.  
  
I have created other visible variables in `group_vars/all/vars.yml` and `roles/containers/vars/main.yml` which point to the encrypted ones in the file mentioned above. You will **need** to create mirror variables inside the vault for each variable.  
  
I am using a [security playbook](https://github.com/geerlingguy/ansible-role-security) which does a couple things like enabling disabling password login on ssh and changing the ssh port. The mentioned playbook does a lot more things so I would recommend checking it out.  
  
Inside the Cloudflare dashboard I recommend setting the SSL/TLS policy to **Full (strict)** as you will have a working certificate generated back in NPM.

## Docker Containers

I am using Nginx Proxy Manager to route traffic to my services containers and so I created a Docker network `proxies` for the client containers to use to connect to NPM.   
As for the list of services I have provided: 
  - nextcloud
  - portainer
  - photoprism
  - vaultwarden
  - wireguard (doesn't run thogh NPM) 
