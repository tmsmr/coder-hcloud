# coder-hcloud
*Terraform based one-shot deployment of [Coder OSS](https://github.com/coder/coder) on a [Hetzner Cloud](https://www.hetzner.com/de/cloud) instance.*

## Quickstart
- Copy `config.auto.tfvars.example` to `config.auto.tfvars`
- Adjust `config.auto.tfvars`
- `terraform init && terraform apply`
- Create DNS records
- Open Coder, login with the initial admin user
- (Install Templates from `coder-templates`)

## A little bit more details

### Configuration/Variables
| Variable      | Default | Description                                                                                             |
|---------------|---------|---------------------------------------------------------------------------------------------------------|
| hcloud_apikey |         | A R/W API-Key for the Hetzner Cloud project Coder shall be deployed in                                  |
| instance_type | cx11    | Instance type (https://www.hetzner.com/de/cloud) for the Coder node                                     |
| location      | ngb1    | Location for the Coder node (nbg1, fsn1, hel1, ash)                                                     |
| coder_domain  |         | Desired Domain for Coder (Used for CODER_ACCESS_URL, CODER_WILDCARD_ACCESS_URL and Caddy/Let's Encrypt) |
| acme_email    |         | Administrative Email address used for Let's Encrypt and for the initial Coder user                      |

### Deployment
*SSH*

Terraform creates keys for the client and the host. The host key is installed later using Cloud-init. The client key is registered in the Hetzner Cloud project and can be used later for regular maintenance tasks. You may use the preconfigured wrapper script `./bin/ssh` for easy access.

*Firewall*

A Hetzner Cloud Firewall is applied. Outgoing traffic is allowed generally. Incoming traffic is restricted to ICMP and HTTP 80, 443.

*Coder installation (Cloud-init)*

Coder is managed via Docker Compose (Adapted from https://github.com/coder/coder/blob/main/docker-compose.yaml).
- First, only Coder and Postgress is started...
- When Coder is ready, the initial admin account is created...
- After that, the Proxy (Caddy) is started as well

*Maintenance*

While the Debian updates are mostly managed via `unattended-upgrades`, **you have to take care of the updates for the Docker Compose stack (`/root/coder/docker-compose.yaml`) manually!**


## Templates

### [hcloud](coder-templates/hcloud)
