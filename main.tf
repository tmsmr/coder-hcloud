resource "tls_private_key" "client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "client" {
  name       = "coder-node-client-key"
  public_key = tls_private_key.client.public_key_openssh
}

resource "tls_private_key" "host" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_server" "node" {
  name         = "coder-node"
  image        = "docker-ce"
  server_type  = var.instance_type
  location   = var.location
  ssh_keys     = [hcloud_ssh_key.client.id]
  firewall_ids = [hcloud_firewall.fw.id]
  user_data    = templatefile("tpl/user_data.yaml", {
    host_ecdsa_private = indent(4, tls_private_key.host.private_key_pem)
    host_ecdsa_public  = tls_private_key.host.public_key_openssh
    coder_version = var.coder_version
    pg_password = random_string.pg_password.result
    coder_domain = var.coder_domain
    pg_version = var.pg_version
    caddy_version = var.caddy_version
    acme_email = var.acme_email
    coder_initial_password = random_string.coder_initial_password.result
  })
}
