data "vault_policy_document" "aws_access" {
  rule {
    path         = local.aws_sts_endpoint
    capabilities = ["read", "update"]
  }
}

resource "vault_policy" "aws_access" {
  name   = "aws_access"
  policy = data.vault_policy_document.aws_access.hcl
}
