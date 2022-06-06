resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_policy" "production" {
  name = "production"

  policy = <<EOT
path "consul/creds/production" {
 capabilities = ["read"]
}
EOT
}


resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://E2F11B3C5E13E4C53B148B1D0026CBCC.gr7.us-west-2.eks.amazonaws.com"
  kubernetes_ca_cert     = "-----BEGIN CERTIFICATE-----\nMIIC5zCCAc+gAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl\ncm5ldGVzMB4XDTIyMDUzMTEzMDY0MVoXDTMyMDUyODEzMDY0MVowFTETMBEGA1UE\nAxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALn5\nmQq0jx91gHybCoc0dZDKtqV6v1eOfR/4pUoZQ8Lco2NySJSwvfD30ulYQo0200h2\ny3A3yrYdz75zhzI2FRUeS+rbkyE1B93lCipfyUZTb2h1gScS25y9Zqr6wIVt4iGA\nDWmuJwnQ13iMyPrlUix9lrgnrQNV4YCW454bfKA2f40ylbSWvPS5Vo/IO3KBb1nD\n7uo5DHQtq0hcynMmwkTNDFsdhWXd5i7rbLfy0B969WJXVHXpDntalJrFb81O1IrA\nJ2KqDaiPnf8zMIorxjGkHptuhqkQgCVFVWnr3+jZFu8VCSt+mf9RQRrZgCqQXwtr\nlZ60mSp2zzozbVm3NCkCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB\n/wQFMAMBAf8wHQYDVR0OBBYEFJQ7PYSBtklJPwxfPedrgbuATA5XMA0GCSqGSIb3\nDQEBCwUAA4IBAQBwGVh0X3bMRDiaPPPQHuln/lFRIhl9whHmsiI0PjiR53EItcwy\nSgiLi1PAW2a0zqtJXotfupfj9bd4UFH1HTrcfEVXJ3V+wV4RTOBR1yJu1JMsFK18\naObYAY0T02NnmVXoCzgJWv5wHfX7dZk1lVvuucA4TYqlDur5SjiclsrT+dTNwkIk\nItAVwGz2ezQBIhJm1m+/Z3GVLssBg2X4rnvPI7ot1DmujWdgJFXZHWlcIR4138x1\nS5zvjwb81OfiFO4jxM+Ki1B6U5PFPaAoJx0M/d/8M0PJKeYMDxY/lIFW5gN1I8zY\npAQdpkgCTUrLqu52BGauOVMbQqd7rc5ZEKq/\n-----END CERTIFICATE-----"
  disable_local_ca_jwt   = true
}

resource "vault_kubernetes_auth_backend_role" "actions-runner-controller" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "actions-runner-controller"
  bound_service_account_names      = ["actions-runner-controller"]
  bound_service_account_namespaces = ["actions-runner-system"]
  token_ttl                        = 3600
  token_policies                   = ["production"]
}

resource "vault_consul_secret_backend" "consul" {
  path                      = "consul"
  description               = "Manages the Consul backend"
  address                   = hcp_consul_cluster.main.consul_private_endpoint_url
  token                     = hcp_consul_cluster_root_token.token.secret_id
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 3600
}

resource "vault_consul_secret_backend_role" "production" {
  name    = "production"
  backend = vault_consul_secret_backend.consul.path
  policies = [
    consul_acl_policy.production_key_admin.name
  ]
  consul_namespace=consul_namespace.production.name
}