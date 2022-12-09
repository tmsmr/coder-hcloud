# coder-hcloud
*One-shot deployment and templates for Coder on Hetzner Cloud*

This project serves two purposes:
- Terraform based deployment of [Coder OSS](https://github.com/coder/coder) on a [Hetzner Cloud](https://www.hetzner.com/de/cloud) instance.
- [Template](https://coder.com/docs/coder-oss/latest/templates)(s) for Coder to create [Workspaces](https://coder.com/docs/coder-oss/latest/workspaces) on Hetzner Cloud instances.

## Coder Deployment

### Quickstart
- Copy `coder/config.auto.tfvars.example` to `coder/config.auto.tfvars`
- Adjust `coder/config.auto.tfvars`
- `cd coder && terraform init && terraform apply`
- Create DNS records
- Open Coder, login with initial admin user

### A little bit more details

#### Configuration
| Variable      | Default | Description                                                                                             |
|---------------|---------|---------------------------------------------------------------------------------------------------------|
| hcloud_apikey |         | A R/W API-Key for the Hetzner Cloud project Coder shall be deployed in                                  |
| instance_type | cx11    | Instance type (https://www.hetzner.com/de/cloud) for the Coder node                                     |
| location      | ngb1    | Location for the Coder node (nbg1, fsn1, hel1, ash)                                                     |
| coder_domain  |         | Desired Domain for Coder (Used for CODER_ACCESS_URL, CODER_WILDCARD_ACCESS_URL and Caddy/Let's Encrypt) |
| acme_email    |         | Administrative Email address used for Let's Encrypt and for the initial Coder user                      |

## Templates

### [hcloud](templates/hcloud)
