terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.6.5"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "coder" {
}

variable "hcloud_token" {
  sensitive = true
}

variable "instance_type" {
  default     = "cpx11"
  description = "https://www.hetzner.com/cloud"
  validation {
    condition = contains([
      "cpx11", "cpx31", "cpx51"
    ], var.instance_type)
    error_message = ""
  }
}

variable "instance_os" {
  default = "docker-ce"

  validation {
    condition = contains([
      "docker-ce", "debian-11"
    ], var.instance_os)
    error_message = ""
  }
}

variable "volume_size" {
  default = "10"
  validation {
    condition     = var.volume_size >= 10
    error_message = ">=10"
  }
}

variable "install_code_server" {
  default = "false"
  validation {
    condition     = contains(["true", "false"], var.install_code_server)
    error_message = ""
  }
}

data "coder_workspace" "me" {
}

resource "coder_agent" "dev" {
  arch = "amd64"
  os   = "linux"
}

resource "coder_app" "vim" {
  agent_id     = coder_agent.dev.id
  slug         = "vim"
  display_name = "Vim"
  icon         = "/icon/memory.svg"
  command      = "vim"
}

resource "coder_app" "code-server" {
  count        = var.install_code_server ? 1 : 0
  agent_id     = coder_agent.dev.id
  slug         = "code-server"
  display_name = "VS Code"
  icon         = "/icon/code.svg"
  url          = "http://localhost:8080"
}

resource "tls_private_key" "dummy" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "dummy" {
  name       = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-dummy"
  public_key = tls_private_key.dummy.public_key_openssh
}

resource "hcloud_volume" "persistence" {
  name     = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-persistence"
  size     = var.volume_size
  format   = "ext4"
  location = "nbg1"
}

resource "hcloud_server" "instance" {
  count       = data.coder_workspace.me.start_count
  name        = "${data.coder_workspace.me.name}"
  server_type = var.instance_type
  location    = "nbg1"
  image       = var.instance_os
  ssh_keys    = [hcloud_ssh_key.dummy.id]
  user_data   = templatefile("cloud-config.yaml.tftpl", {
    username          = data.coder_workspace.me.owner
    volume_path       = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.persistence.id}"
    init_script       = base64encode(coder_agent.dev.init_script)
    coder_agent_token = coder_agent.dev.token
    code_server_setup = var.install_code_server
  })
}

resource "hcloud_volume_attachment" "vol_attach" {
  count     = data.coder_workspace.me.start_count
  volume_id = hcloud_volume.persistence.id
  server_id = hcloud_server.instance[count.index].id
  automount = false
}

resource "hcloud_firewall" "fw" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-fw"
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall_attachment" "fw_attach" {
  count       = data.coder_workspace.me.start_count
  firewall_id = hcloud_firewall.fw.id
  server_ids  = [hcloud_server.instance[count.index].id]
}
