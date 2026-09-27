# Traffic handling

## Comment une requête arrive jusqu'à l'application

Le client contacte l'Application Load Balancer (ALB), seul point d'entrée public. L'ALB répartit chaque requête vers une des instances applicatives disponibles, dans un des deux subnets privés. Ces instances font tourner PrestaShop dans un conteneur Docker.

## Montée en charge

Le nombre d'instances applicatives s'ajuste automatiquement en fonction du CPU moyen utilisé : au-delà d'un certain seuil, une instance supplémentaire est démarrée ; en dessous, une instance est retirée. Ce nombre varie aussi selon l'environnement (1 instance en dev, 2 à 4 en production).

## Si une instance devient indisponible

L'ALB détecte qu'une instance ne répond plus correctement et arrête de lui envoyer du trafic — les autres instances continuent de servir les clients sans interruption visible. L'instance en panne est ensuite remplacée automatiquement par une nouvelle.

**Limite actuelle** : cette nouvelle instance démarre "nue" (système de base uniquement). La configuration applicative (Docker, montage du stockage partagé, déploiement de PrestaShop) n'est pas réappliquée automatiquement — il faut relancer manuellement le déploiement Ansible pour qu'elle rejoigne réellement le service. C'est un choix assumé : automatiser entièrement cette étape demanderait un mécanisme que le projet ne couvre pas.

## Autres limites

- La sortie internet des instances passe par une seule passerelle NAT (pas redondée par zone) : un incident dessus couperait leur accès sortant, sans affecter la disponibilité de l'application elle-même côté visiteurs.
