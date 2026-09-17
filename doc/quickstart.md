# Quickstart

## Prérequis

- Terraform >= 1.6
- Un accès AWS configuré (credentials/profile), via un IAM user (pas root)
- Le backend S3/DynamoDB déjà en place — voir [backend-setup.md](backend-setup.md)

## Déploiement

Trois environnements existent (`dev`, `staging`, `prod`), chacun avec son propre fichier de variables (`terraform/environments/<env>.tfvars`) et son propre fichier state dans le bucket S3 partagé (voir [backend-setup.md](backend-setup.md)). Chaque environnement se déploie avec deux commandes : un `init` qui pointe vers sa clé de state, puis un `apply` avec son fichier de variables.

**Dev :**
```sh
terraform -chdir=terraform init -backend-config="key=dev/terraform.tfstate"
terraform -chdir=terraform apply -var-file=environments/dev.tfvars
```

**Staging :**
```sh
terraform -chdir=terraform init -reconfigure -backend-config="key=staging/terraform.tfstate"
terraform -chdir=terraform apply -var-file=environments/staging.tfvars
```

**Prod :**
```sh
terraform -chdir=terraform init -reconfigure -backend-config="key=prod/terraform.tfstate"
terraform -chdir=terraform apply -var-file=environments/prod.tfvars
```

`-reconfigure` n'est nécessaire que pour basculer d'un environnement à l'autre dans un dossier de travail déjà initialisé (par exemple pour tester les trois depuis le même poste) — pas sur un premier `init` après un clone frais.

Chaque environnement crée : le VPC et ses 6 subnets (2 publics, 2 privés, 2 database), l'Internet Gateway, le NAT Gateway, les route tables, les 4 security groups, ainsi que l'Auto Scaling Group applicatif derrière son Application Load Balancer. Seules la taille/le nombre d'instances diffèrent entre environnements (voir [architecture.md](architecture.md)).
