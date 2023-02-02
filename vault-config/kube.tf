resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "breakfast-table"
  }
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = "waffles"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
}

resource "helm_release" "vault_inject" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  atomic           = true
  max_history      = 5
  timeout          = 120
  namespace        = "vault"
  create_namespace = true

  set {
    name  = "global.enabled"
    value = "false"
  }
  set {
    name  = "global.externalVaultAddr"
    value = local.vault_addr
  }
  set {
    name  = "injector.enabled"
    value = "true"
  }
  set {
    name  = "injector.revokeOnShutdown"
    value = "true"
  }
  set {
    name  = "injector.authPath"
    value = join("/", flatten([local.vault_ns, "auth", vault_jwt_auth_backend.kubernetes.path]))
  }
}

resource "kubernetes_deployment_v1" "sample" {
  metadata {
    name      = "sample-app"
    namespace = kubernetes_service_account_v1.this.metadata.0.namespace
  }

  spec {
    replicas = var.sample_app ? 1 : 0

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"       = "true"
          "vault.hashicorp.com/agent-cache-enable" = "true"
          "vault.hashicorp.com/role"               = vault_jwt_auth_backend_role.default.role_name

          # Inject creds
          "vault.hashicorp.com/agent-inject-secret-awscreds" = "${local.vault_ns}/${local.aws_sts_endpoint}"
          "vault.hashicorp.com/agent-inject-template-awscreds" = <<EOH
          {{- with secret "${local.vault_ns}/${local.aws_sts_endpoint}" "role_session_name=vault-agent" -}}
          [default]
          aws_access_key_id = {{ .Data.access_key }}
          aws_secret_access_key = {{ .Data.secret_key }}
          aws_session_token = {{ .Data.security_token }}
          {{- end }}
          EOH
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.this.metadata.0.name

        container {
          image = "docker.io/amazon/aws-cli:latest"
          name  = "aws-cli"

          command = ["/bin/sh"]
          args = [
            "-c",
            "while true; do aws sts get-caller-identity; sleep 3; done",
          ]

          env {
            name = "AWS_SHARED_CREDENTIALS_FILE"
            value = "/vault/secrets/awscreds"
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.vault_inject,
  ]
}
