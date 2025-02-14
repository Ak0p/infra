# Home Lab Ansible Config
A simple home lab config, heavily inspired from [this repo](https://github.com/notthebee/infra).

This config aims to create a secure self hosted environment.
   
It uses Docker compose to create the containers for the services which are to be hosted on the machine.  
  
The target OS is RHEL/Fedora based.   
  

## Structure  
Inside `/server` are all the services that are exposed via **Traefik** and inside `/pi` are the various monitoring containers and Wireguard.  

Traefik is configured to work on the default HTTP and HTTPS ports and will automatically pick up any new services configured via **labels**.  

For each new service a subdomain is required to be set up in order for Traefik to be able to forward the traffic to the container.  

A [config file](https://github.com/timothymiller/cloudflare-ddns?tab=readme-ov-file#-example-) named `config.json` will need to be added inside the `/server/roles/services/templates/` folder for the CloudflareDDNS container to be able to set up the domains.  
  

  
## Security

The config uses the builtin ansible vault module to store all sensitive data in `group_vars/all/vault.yml`.  
  
Sensitive information is stored inside the encrypted vault file and written into files using [ variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html) and the [template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) module.
  
I am using a [security playbook](https://github.com/geerlingguy/ansible-role-security) which does a couple things like enabling disabling password login on ssh and changing the ssh port. The mentioned playbook does a lot more things so I would recommend checking it out.  
  
Since Traefik is using Let's Encrypt certificates I recommend setting the SSL/TLS policy to **Full (strict)** inside the Cloudflare dashboard.

## Docker Containers

I created a special Docker network `proxy` which is shared by all publicly exposed services and Traefik.  

Any new service will need to be added to this network in order for Traefik to work.  

If a container needs to be part of another network as well the following label will need to be added: `traefik.docker.network=proxy`.  

## Backup  

Restic is set up to back up all docker containers that are using bindings into the `restic_backup_location` directory.  

## Container Updates  

Watchtower is set up to autoupdate all containers but CloudflareDDNS.  

