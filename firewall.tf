resource "hcloud_firewall" "fw" {
  name = "coder-node-firewall"
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
