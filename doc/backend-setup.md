# Backend setup

Le state Terraform est stocké à distance sur S3 (avec verrouillage via DynamoDB) plutôt qu'en local, pour que l'équipe partage le même state et évite les applies concurrents. Ce backend doit exister **avant** le premier `terraform init` — Terraform ne peut pas provisionner lui-même les ressources qui stockent son propre state.

## Prérequis

- Un compte AWS partagé par l'équipe.
- Un IAM user par personne (pas le compte root), avec la policy `AdministratorAccess`.
- AWS CLI configuré avec ces identifiants (`aws configure`).

## Création du bucket S3 et de la table DynamoDB (une seule fois)

```sh
aws s3api create-bucket \
  --bucket taylor-shift-tfstate-819109475304 \
  --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3

aws s3api put-bucket-versioning \
  --bucket taylor-shift-tfstate-819109475304 \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket taylor-shift-tfstate-819109475304 \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws dynamodb create-table \
  --table-name taylor-shift-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-3
```

Le versioning protège contre une corruption/écrasement accidentel du state ; le blocage d'accès public empêche toute exposition publique du bucket, même par erreur.

## Configuration Terraform

Le bloc backend est déjà déclaré dans `terraform/providers.tf` :

```hcl
backend "s3" {
  bucket         = "taylor-shift-tfstate-819109475304"
  key            = "terraform.tfstate"
  region         = "eu-west-3"
  encrypt        = true
  dynamodb_table = "taylor-shift-tfstate-lock"
}
```

Une fois le bucket et la table créés, chaque membre de l'équipe n'a plus qu'à lancer `terraform -chdir=terraform init` pour se connecter au backend partagé.
