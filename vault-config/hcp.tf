resource "hcp_hvn" "this" {
  hvn_id         = var.hvn_name
  cloud_provider = "aws"
  region         = "us-east-1"
}

resource "hcp_vault_cluster" "this" {
  hvn_id          = hcp_hvn.this.hvn_id
  cluster_id      = "hashitalks-demo"
  tier            = "dev"
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "this" {
  cluster_id = hcp_vault_cluster.this.cluster_id
}

locals {
  vault_addr = hcp_vault_cluster.this.vault_public_endpoint_url
  vault_ns   = hcp_vault_cluster.this.namespace
}
