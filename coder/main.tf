resource "tls_private_key" "client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_private_key" "host" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "client" {
  name       = "coder-admin"
  public_key = tls_private_key.client.public_key_openssh
}

resource "random_string" "pg_pass" {
  length  = 32
  special = false
}

resource "random_string" "coder_init_pass" {
  length  = 32
  special = false
}

resource "hcloud_firewall" "coder" {
  name = "coder-public"
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = 80
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = 443
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}


resource "hcloud_server" "coder" {
  name         = "coder"
  image        = "docker-ce"
  server_type  = var.instance_type
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.client.id]
  firewall_ids = [hcloud_firewall.coder.id]
  user_data    = templatefile("tpl/user_data.yaml", {
    host_ecdsa_private = indent(4, tls_private_key.host.private_key_pem)
    host_ecdsa_public  = tls_private_key.host.public_key_openssh
    coder_version      = var.coder_version
    pg_pass            = random_string.pg_pass.result
    coder_domain       = var.coder_domain
    pg_version         = var.pg_version
    caddy_version      = var.caddy_version
    acme_email         = var.acme_email
    coder_init_pass    = random_string.coder_init_pass.result
  })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "local_file" "known_hosts" {
  content         = "${hcloud_server.coder.ipv4_address} ${tls_private_key.host.public_key_openssh}"
  filename        = "gen/known_hosts"
  file_permission = "644"
}

resource "local_file" "client_key" {
  content         = tls_private_key.client.private_key_pem
  filename        = "gen/id_ecdsa"
  file_permission = "600"
}

resource "local_file" "ssh_script" {
  content = templatefile("tpl/ssh.sh", {
    ip = hcloud_server.coder.ipv4_address
  })
  filename        = "bin/ssh"
  file_permission = "700"
  depends_on      = [local_file.known_hosts]
}
