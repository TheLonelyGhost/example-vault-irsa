resource "aws_iam_user" "vault" {
  name          = "hcp-vault"
  force_destroy = true
}

data "aws_iam_policy_document" "vault_assume_roles" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      aws_iam_role.s3_ro.arn,
    ]
  }
}

resource "aws_iam_user_policy" "vault_assume_roles" {
  name = "hcp-vault-assume-roles"
  user = aws_iam_user.vault.name

  policy = data.aws_iam_policy_document.vault_assume_roles.json
}

data "aws_iam_policy_document" "vault_trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_user.vault.arn,
      ]
    }
  }
}

resource "aws_iam_role" "s3_ro" {
  name = "s3-readonly"

  assume_role_policy = data.aws_iam_policy_document.vault_trust_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}


resource "vault_aws_secret_backend" "this" {
  path = "aws"

  access_key = aws_iam_access_key.vault.id
  secret_key = aws_iam_access_key.vault.secret
}

resource "vault_aws_secret_backend_role" "s3_ro" {
  backend = vault_aws_secret_backend.this.path
  name = "s3-ro"
  credential_type = "assumed_role"
  role_arns = [
    aws_iam_role.s3_ro.arn,
  ]
}

locals {
  aws_sts_endpoint = "${vault_aws_secret_backend.this.path}/sts/${vault_aws_secret_backend_role.s3_ro.name}"
}
