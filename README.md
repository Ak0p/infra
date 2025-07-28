# Home Lab Config

This repository holds all files for the configuration of all services I host at home.


## Goals

**With this project I aim to develop my automations skills by leveraging various technologies and best practices.**

I also aim to make all configurations reproducible by leveraging as many IaC tools as possible.

## Tooling

### Virtualization

I run Proxmox VE on multiple nodes in order to balance the load and to use the High Availability feature (TODO).

The reason I chose Proxmox over Kubernetes is because I wanted to run multiple VM's and for security when it matters.

### Containerization

I run my containers on a Fedora CoreOS VM using Docker because I already had an Ansible playbook for easy deployment of all services.

I plan on using LXC's directly on the hypervisor for services that would be classified as essential, such as VPN and DNS.

### Provisioning and Deployment

For VM and LXC provisioning I am using Terraform with the Proxmox provider. I store all sensitive data in a Hashicorp Vault container locally.

For container deployments and additional configurations I am using Ansible. All sensitive data is stored in an Ansible Vault encrypted file.

I plan on using a CI/CD tool such as GitHub Actions in order to run the steps of deployment automatically.

## Structure

I run multiple virtual machines for different purposes.

### Fedora CoreOS

I chose CoreOS because it is reproducible and offers automatic updates.

On this VM I run all services such as Nextcloud and Immich through a Traefik reverse proxy that exposes them publicly.

### Home Assistant OS

I run a dedicated HA VM because I intend on using addons, which can only be run on the OS version of Home Assistant, and because I plan on using the high availability feature in the future.

### TrueNas (TODO)

### Wireguard LXC (TODO)

### CloudflareDDNS LXC (TODO)

### PiHoleDNS LXC (TODO)

### Monitoring Stack (TODO)