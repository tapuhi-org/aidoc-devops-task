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
  kubernetes_host        = module.eks.cluster_endpoint
  kubernetes_ca_cert     = module.eks.cluster_certificate_authority_data
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