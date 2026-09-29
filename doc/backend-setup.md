# Backend setup

Le state Terraform est stocké à distance sur S3 (avec verrouillage natif S3) plutôt qu'en local, pour que l'équipe partage le même state et évite les applies concurrents. Ce backend doit exister **avant** le premier `terraform init`, car Terraform ne peut pas provisionner lui-même les ressources qui stockent son propre state.

## Prérequis

- Un compte AWS partagé par l'équipe.
- Un IAM user par personne (pas le compte root), avec la policy `AdministratorAccess`.
- AWS CLI configuré avec ces identifiants (`aws configure`).

## Création du bucket S3 (une seule fois)

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
```

Le versioning protège contre une corruption ou un écrasement accidentel du state. Le blocage d'accès public empêche toute exposition publique du bucket, même par erreur. Pas de table DynamoDB à créer : le verrouillage utilise le mécanisme natif de S3 (`use_lockfile`), plus besoin d'une ressource séparée pour ça.

## Configuration Terraform

Le bloc backend est déjà déclaré dans `terraform/providers.tf` :

```hcl
backend "s3" {
  bucket       = "taylor-shift-tfstate-819109475304"
  region       = "eu-west-3"
  encrypt      = true
  use_lockfile = true
}
```

`bucket` et `region` sont partagés par les trois environnements (dev/staging/prod), un seul bucket suffit, le verrouillage étant scopé par bucket et clé. La clé du state (`key`) n'est volontairement pas fixée ici, car un bloc `backend` ne peut pas utiliser de variable Terraform : elle est donc fournie explicitement à chaque `init`, pour que chaque environnement écrive dans son propre fichier state au sein du même bucket, sans jamais se marcher dessus. Voir [quickstart.md](quickstart.md) pour les commandes exactes par environnement.
