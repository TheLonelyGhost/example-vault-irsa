resource "vault_jwt_auth_backend" "kubernetes" {
  description            = "Shim for Kubernetes authentication, but one-way due to network constraints"
  type                   = "jwt"
  path                   = "kubernetes"
  jwt_validation_pubkeys = var.jwt_signer_pubkeys
}

resource "vault_jwt_auth_backend_role" "default" {
  backend   = vault_jwt_auth_backend.kubernetes.path
  namespace = vault_jwt_auth_backend.kubernetes.namespace
  role_type = "jwt"
  role_name = "default"

  token_policies = [
    "default",
    vault_policy.aws_access.name,
  ]

  user_claim    = "sub"
  bound_audiences = [
    "https://kubernetes.default.svc.cluster.local",
  ]
  bound_subject = format(
    "system:serviceaccount:%s:%s",
    kubernetes_service_account_v1.this.metadata.0.namespace,
    kubernetes_service_account_v1.this.metadata.0.name,
  )
}
