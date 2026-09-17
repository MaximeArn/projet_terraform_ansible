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
  region         = "eu-west-3"
  encrypt        = true
  dynamodb_table = "taylor-shift-tfstate-lock"
}
```

`bucket`, `region` et `dynamodb_table` sont partagés par les trois environnements (dev/staging/prod) — un seul bucket, un seul verrou DynamoDB suffisent, le verrouillage étant scopé par bucket+clé. La clé du state (`key`) n'est volontairement pas fixée ici, car un bloc `backend` ne peut pas utiliser de variable Terraform : elle est donc fournie explicitement à chaque `init`, pour que chaque environnement écrive dans son propre fichier state au sein du même bucket, sans jamais se marcher dessus. Voir [quickstart.md](quickstart.md) pour les commandes exactes par environnement.
