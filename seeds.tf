resource "random_string" "pg_password" {
  length  = 32
  special = false
}

resource "random_string" "coder_initial_password" {
  length  = 32
  special = false
}
