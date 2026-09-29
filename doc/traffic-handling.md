# Traffic handling

## Comment une requête arrive jusqu'à l'application

Le client contacte l'Application Load Balancer (ALB), seul point d'entrée public. L'ALB répartit chaque requête vers une des instances applicatives disponibles, dans un des deux subnets privés. Ces instances font tourner PrestaShop dans un conteneur Docker.

## Montée en charge

Le nombre d'instances applicatives s'ajuste automatiquement en fonction du CPU moyen utilisé : au-delà d'un certain seuil, une instance supplémentaire est démarrée ; en dessous, une instance est retirée. Ce nombre varie aussi selon l'environnement (1 instance en dev, 2 à 4 en production).

## Si une instance devient indisponible

L'ALB détecte en temps réel qu'une instance ne répond plus correctement (panne applicative comprise, pas seulement une panne système) et arrête immédiatement de lui envoyer du trafic. Les autres instances continuent de servir les clients sans interruption visible.

Le remplacement automatique de l'instance par l'Auto Scaling Group, lui, se base uniquement sur l'état système, pas sur la santé applicative. C'est un choix délibéré : une nouvelle instance démarre "nue" et sa configuration applicative (Docker, montage du stockage partagé, déploiement de PrestaShop) n'est pas automatique, il faut relancer manuellement le déploiement Ansible pour qu'elle rejoigne réellement le service. Si le remplacement se basait sur la santé applicative, l'ASG remplacerait en boucle une instance en cours de reconfiguration manuelle, avant même de lui laisser le temps d'être prête. Dans un contexte où la configuration des nouvelles instances serait elle aussi automatisée (auto-configuration au démarrage), ce choix serait revu pour se baser sur la santé applicative de bout en bout.

## Autres limites

- La sortie internet des instances passe par une seule passerelle NAT (pas redondée par zone) : un incident dessus couperait leur accès sortant, sans affecter la disponibilité de l'application elle-même côté visiteurs.
