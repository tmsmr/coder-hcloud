resource "local_file" "known_hosts" {
  content         = "${hcloud_server.node.ipv4_address} ${tls_private_key.host.public_key_openssh}"
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
    ip = hcloud_server.node.ipv4_address
  })
  filename        = "bin/ssh"
  file_permission = "700"
  depends_on      = [local_file.known_hosts]
}
