provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-k3s-default"
}
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-k3s-default"
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}
provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address   = local.vault_addr
  namespace = local.vault_ns
  token     = hcp_vault_cluster_admin_token.this.token
}
