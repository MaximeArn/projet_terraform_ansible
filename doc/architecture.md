# Architecture

Infrastructure AWS pour PrestaShop (Taylor Shift's Ticket Shop), provisionnée avec Terraform et configurée avec Ansible. Objectif : rester disponible et réactive pendant les pics de vente de billets.

## Réseau

- 1 VPC, réparti sur 2 zones de disponibilité.
- 3 tiers de subnets (public, app-private, data-private), chacun présent dans les 2 AZ :
  - **public** : uniquement l'ALB.
  - **app-private** : instances EC2 de l'ASG, points de montage EFS.
  - **data-private** : instance RDS.
- 1 NAT Gateway partagé (pas un par AZ) pour la sortie internet des subnets privés — léger SPOF accepté sur la sortie, sans impact sur la haute dispo de l'ALB/ASG.
- Aucun accès SSH exposé : administration des instances via AWS SSM Session Manager. Aucune IP publique sur les instances applicatives.

## Compute

- Un Auto Scaling Group de 2 instances EC2 (t3.small) dans les subnets `app-private`, derrière un Application Load Balancer public.
- Politique de scaling en target-tracking sur le CPU.
- PrestaShop tourne en conteneur Docker (image officielle Docker Hub), déployé et configuré par Ansible.

## Stockage partagé

- PrestaShop écrit par défaut sur le disque local (médias, cache, sessions). Pour scaler horizontalement, ces données doivent être partagées entre les instances : un volume EFS est monté sur chaque instance de l'ASG.

## Base de données

- RDS MySQL (moteur natif de PrestaShop).
- Single-AZ par défaut ; le Multi-AZ reste une option activable (variable) pour un scénario "prod", sans être le réglage par défaut.

## Secrets

- Ansible Vault est l'unique source de vérité pour le mot de passe de la base de données. Pas de service AWS dédié (Secrets Manager) — le budget n'étant pas une contrainte forte, ce choix est motivé par la simplicité et le respect direct des critères de notation sur la gestion des secrets.

## Organisation Terraform

- Modules dédiés : `network`, `compute`, `database`, `storage`.
- Séparation des environnements (dev/staging/prod) via un fichier `.tfvars` par environnement dans `terraform/environments/`.
