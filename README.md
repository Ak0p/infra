# Home Lab Config

This repository holds all files for the configuration of all services I host at home.


## Goals

**With this project I aim to develop my automations skills by leveraging various technologies and best practices.**

I also aim to make the maintanance of my home lab as easy as possible, due to the many services I intend to deploy.

## Tooling

### Virtualization

I chose to run ProxmoxVE because I intend to run multiple VMs and my container deployment infrastructure is already written in Ansible.
I also use High Availability for services such as local DNS.

### Containerization

I run almost all services on a Fedora CoreOS VM using Docker.

I plan on using LXC's for more important services, such as a Hashicorp Vault deployment or a PiHole DNS server.

### Provisioning and Deployment

For VM and LXC provisioning I use Terraform with the [Proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest) provider. I store all sensitive data in a Hashicorp Vault instance.

For container deployments and additional configurations I use Ansible. For secrets management I use the built in [Ansible Vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) module.

I plan on integrating CI/CD tooling such as [Proxmox GitOps](https://github.com/moosebt/proxmox-gitops) in the future.

## Structure

I run multiple virtual machines for different purposes.

### Fedora CoreOS

I chose CoreOS because it is reproducible and offers automatic updates.

This VM hosts all services such as [Nextcloud](https://nextcloud.com/) and [Immich](https://immich.app/) through a [Traefik](https://traefik.io/traefik) reverse proxy that exposes them publicly.

### Home Assistant OS

Home Assistant is a platform for IOT devices that can use integrations to build powerful automations.

### TrueNas (TODO)

### PiHoleDNS LXC (TODO)

### Monitoring Stack (TODO)



## Security and authentication

I have several services that are exposed publicly and other administration interfaces that I would prefer to benefit from the additional security of MFA (Multi-Factor Authentication).
With these requirements in mind I deployed an [Authentik](https://goauthentik.io/) instance that handles Single Sing-On on all services.

I also plan on using CrowdSec for further threat protection.