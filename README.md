# Projet IaC
L'objectif est de mettre en place l'infrastructure nécessaire au déploiement de l'application de billetterie Taylor Shift's Ticket Shop sur AWS.

Le projet utilise principalement :
- Terraform pour créer l'infrastructure
- Ansible pour configurer les serveurs et déployer l'application
- Docker pour faire tourner l'application
- AWS pour l'infrastructure et les services utilisés

L'application étant déjà développée, notre travail porte principalement sur la partie infrastructure, déploiement, configuration et automatisation.



## Notions importantes
- **Infrastructure** : fait référence à l’ensemble sous-jacent de ressources informatiques, de composants réseau et de services requis pour héberger, déployer et exécuter l’application. Il englobe tous les composants physiques et virtuels qui soutiennent le fonctionnement de l’application.

- **Infrastructure as Code (IaC)** : est une approche de provisionnement, de configuration et de gestion des ressources d’infrastructure à l’aide d’outils d’automatisation et de codes lisibles par machine. Il implique l’utilisation de code déclaratif ou impératif pour définir les composants d’infrastructure, y compris les serveurs, les réseaux, le stockage et d’autres ressources, d’une manière cohérente et reproductible.

- **Terraform** : est un outil IaC polyvalent qui se concentre sur le provisionnement d’infrastructures. Il utilise un langage de configuration déclaratif (HCL) pour définir les ressources et leurs relations. La gestion des états de Terraform aide à planifier et à appliquer les changements en toute sécurité.



## Notes prises au fur et à mesure pour la documentation finale
Le projet utilise **Terraform** pour provisionner automatiquement l'infrastructure AWS.

Au lieu de créer les ressources manuellement depuis la console AWS, nous les décrivons dans du code. 
Cela permet de pouvoir recréer la même infrastructure facilement et de manière reproductible.

Notre projet Terraform est organisé autour de fichiers de configuration principaux et de modules dédiés aux différentes parties de l'infrastructure, comme par exemple le module *network* regroupera les ressources liées au réseau.
L'objectif de cette organisation est de séparer les différentes responsabilités de l'infrastructure et de rendre chaque partie réutilisable.



### Elements mis en place 
- Mise en place de la base Terraform avec le provider AWS
- Création du module network et du VPC 10.0.0.0/16
- Utilisation de variables pour gérer la région et l'environnement (dev, staging, prod)



### Structure du projet
terraform/
    - main.tf
    - providers.tf
    - variables.tf
    - outputs.tf
    - modules/
        - network/
            - main.tf
            - variables.tf
            - outputs.tf