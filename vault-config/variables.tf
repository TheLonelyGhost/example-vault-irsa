variable "hcp_client_id" {
  description = "Service Principal key's client_id (HCP)"
  type        = string
  sensitive   = true
}

variable "hcp_client_secret" {
  description = "Service Principal key's client_secret (HCP)"
  type        = string
  sensitive   = true
}

variable "hvn_name" {
  description = "Name of your HashiCorp Cloud Platform virtual network"
  type        = string
  default     = "hvn"
}

variable "jwt_signer_pubkeys" {
  description = "See https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/kubernetes#using-jwt-validation-public-keys"
  type        = list(string)
}

variable "sample_app" {
  description = "Create the sample application that consumes from the Vault api?"
  type        = bool
  default     = false
}
