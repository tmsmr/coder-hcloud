output "instructions" {
  value = <<EOT

  ############
  # required DNS-records
  #   ${var.coder_domain}. A ${hcloud_server.coder.ipv4_address}
  #   *.${var.coder_domain}. CNAME ${var.coder_domain}.
  #
  # initial user (admin)
  #   ${var.acme_email}
  #   ${random_string.coder_init_pass.result}
  #
  # SSH access
  #   client key: ./gen/id_ecdsa
  #   host fingerprint: ./gen/known_hosts
  #   wrapper script: ./bin/ssh
  ############
  EOT
}
