# IRSA Evolved: HashiCorp Vault Edition

An example project that demonstrates how to include AWS access to your Kubernetes workload, without your workload knowing it is talking to Vault, while taking advantage of existing AWS secrets engines, and without the limitations of the IRSA implementation.

## Requirements

### Tools

- `k3d`
- `kubectl`
- `jq`
- `terraform`

### Systems Access

- AWS account (clean slate is best) with credentials to modify IAM settings
- HashiCorp Cloud Platform account with a Service Principal (and keys)

## Setup

```bash
~/src $ k3d cluster create k3d-k3s-default
~/src $ kubectl get --raw "$(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri' | sed -r 's/.*\.[^/]+(.*)/\1/')"
```

- Take the resulting JWK and convert it to a PEM using <https://8gwifi.org/jwkconvertfunctions.jsp>
- Set the resulting PEM(s) as entries in `jwt_signer_pubkeys` tfvar value
- Get a HashiCorp Cloud Platform client_id and client_secret, setting them as `hcp_client_id` and `hcp_client_secret` tfvars, respectively
- Configure a foothold (IAM user?) in your AWS account and set the credentials as environment variables (or choose your AWS profile and local CLI configuration)

```bash
~/src $ terraform init
~/src $ terraform apply
```

Review the changes and, if okay with them, say "yes" to finish applying. The HCP Vault cluster may take some time to create and become fully available.
