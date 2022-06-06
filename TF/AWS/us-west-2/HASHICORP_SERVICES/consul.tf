
resource "consul_namespace" "production" {
  name        = "production"
  description = "Production namespace"

}


resource "consul_acl_policy" "production_key_admin" {
  name        = "production_key_admin"
  rules       = <<-RULE
    key_prefix "" {
      policy = "write"
    }
    RULE
  namespace = consul_namespace.production.name
}



