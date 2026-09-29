# Architecture

Infrastructure AWS pour PrestaShop (Taylor Shift's Ticket Shop), provisionnée avec Terraform et configurée avec Ansible. Objectif : rester disponible et réactive pendant les pics de vente de billets.

## Réseau

- **VPC** : réseau privé isolé, réparti sur 2 zones de disponibilité pour tolérer la perte d'une AZ sans interrompre le service.
- **Internet Gateway** : porte d'entrée/sortie du VPC vers Internet, utilisée par l'ALB (trafic entrant) et le NAT Gateway (trafic sortant).
- **3 tiers de subnets**, chacun présent dans les 2 AZ, pour isoler les composants selon ce qu'ils doivent exposer :
  - **public** : héberge uniquement l'ALB, seul élément qui doit être joignable depuis Internet.
  - **private** : héberge les instances EC2 de l'ASG (PrestaShop). Aucune IP publique, jamais exposées directement.
  - **database** : héberge RDS, isolée du reste, n'accepte que le trafic venant des instances applicatives.
- **NAT Gateway** (partagé, pas un par AZ) : permet aux instances des subnets privés de sortir vers Internet (mises à jour système, image Docker, agent SSM) sans avoir elles-mêmes d'IP publique. Léger SPOF accepté sur la sortie, sans impact sur la haute dispo de l'ALB/ASG qui restent répartis sur les 2 AZ.
- **Aucun accès SSH exposé** : administration des instances via AWS SSM Session Manager, qui ne nécessite ni port entrant ouvert ni clé SSH à gérer.
- **Security groups en chaîne**, sans règle basée sur des CIDR pour le trafic interne : chaque SG n'autorise que le SG qui le précède dans la chaîne, jamais une plage d'IP.
  - `alb` : accepte Internet sur le port applicatif, seule entrée publique de l'infrastructure.
  - `app` : n'accepte que le SG `alb`, les instances ne sont joignables que via l'ALB.
  - `database` et `efs` : n'acceptent que le SG `app`, seules les instances applicatives peuvent y accéder.

## Compute

- Un Auto Scaling Group d'instances EC2 dans les subnets `private`, derrière un Application Load Balancer public. Taille et nombre d'instances varient par environnement (voir plus bas).
- Politique de scaling en target-tracking sur le CPU.
- PrestaShop tourne en conteneur Docker (image officielle Docker Hub), déployé et configuré par Ansible.
- Le remplacement automatique d'instance par l'ASG se base sur la santé système, pas sur la santé applicative (voir [traffic-handling.md](traffic-handling.md) pour la justification de ce choix).

## Stockage partagé

- PrestaShop écrit par défaut sur le disque local (médias, cache, sessions). Pour scaler horizontalement, ces données doivent être partagées entre les instances : un volume EFS est monté sur chaque instance de l'ASG.

## Base de données

- RDS MySQL (moteur natif de PrestaShop), single-AZ.

## Secrets

- Ansible Vault est l'unique source de vérité pour les secrets (mot de passe de la base de données, mot de passe administrateur PrestaShop). Pas de service AWS dédié (Secrets Manager), le budget n'étant pas une contrainte forte, ce choix est motivé par la simplicité et le respect direct des critères de notation sur la gestion des secrets.

## Organisation Terraform

- Modules dédiés : `network`, `compute`, `database`, `storage`.
- Séparation des environnements (dev/staging/prod) via un fichier `.tfvars` par environnement dans `terraform/environments/`, et une clé de state distincte par environnement dans le même bucket S3 (voir [backend-setup.md](backend-setup.md)).
  - `dev` : 1 instance `t3.micro` (min 1, max 2), itération rapide, coût minimal.
  - `staging` : 1 instance `t3.small` (min 1, max 2), même gabarit que prod, échelle réduite.
  - `prod` : 2 instances `t3.small` (min 2, max 4), haute disponibilité réelle.
