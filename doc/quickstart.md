# Quickstart

## Prérequis

- Terraform >= 1.6
- Un accès AWS configuré (credentials/profile), via un IAM user (pas root)
- Le backend S3/DynamoDB déjà en place — voir [backend-setup.md](backend-setup.md)

## Déploiement

```sh
cd terraform
terraform init
terraform apply -var-file=environments/dev.tfvars
```

Crée le VPC et ses 6 subnets (2 publics, 2 privés, 2 database), l'Internet Gateway, le NAT Gateway et les route tables.
