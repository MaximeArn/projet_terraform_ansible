# Quickstart

## Prérequis

- Terraform >= 1.6
- Un accès AWS configuré (credentials/profile)

## Déploiement

```sh
cd terraform
terraform init
terraform apply -var-file=environments/dev.tfvars
```

Crée le VPC et ses 6 subnets (2 publics, 2 app-private, 2 data-private).
