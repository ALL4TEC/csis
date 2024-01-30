```sh
.  # Dossier racine du projet
├── app  # Dossier principal de l'application Rails
|   ├── assets # Assets gérés par rails sprockets
│   ├── channels  # Canaux de communications en temps réel (non utilisé)
│   ├── comparators  # Entities comparators
│   ├── controllers  # Les contrôleurs de l'application
│   ├── decorators  # Les décorateurs des modèles
│   ├── errors  # Classes et gestionnaires d'erreurs non génériques
│   ├── handlers  # Gestionnaires de formulaires
│   ├── headers  # Maps des en-têtes disponibles par entité
│   ├── helpers  # Fonctions utilitaires
│   ├── inputs  # Types de champs personnalisés pour les formulaires
│   ├── javascript  # Assets gérés par webpacker (JS & CSS)
│   │    ├── controllers # controllers stimulus
│   │    ├── images # Images packagées par webpack
│   │    ├── packs # Javascript
│   │    ├── stylesheets # CSS
│   ├── jobs  # Tâches de fonds
│   ├── lambdas  # Méthodes retournant des lambdas
│   ├── mailers  # Fonctions d'envoi de mail
│   ├── managers  # Manageurs d'entités
│   ├── mappers  # Mappeurs entre le model CSIS et les différentes données importées
│   ├── models  # Modèles de l'application
│   ├── policies  # Autorisations et scopes
│   ├── predicates  # Prédicats d'entités
│   ├── schedulers  # Schedulers
│   ├── services  # Services
│   ├── utils  # Utilitaires
│   ├── validators  # Valideurs
│   └── views  # Templates HTML de l'application
├── bin  # Fichiers executables fournis par Rails & ses dépendances
├── ci  # Scripts utilisé lors de l'intégration continue
├── config  # Fichiers de configuration de l'application
│   ├── environments  # Fichiers spécifiques à un environnement
│   ├── initializers  # Scripts de configuration des dépendances
│   ├── locales  # Fichiers de traduction
│   └── webpack  # Configuration de webpack, outil utilisé pour gérer les fichiers Javascript & CSS
├── db  # Fichiers relatifs à la base de données
│   └── migrate  # Migrations de la base de données
├── docker  # Fichiers relatifs à docker
├── doc  # Documentation générée par la commande `rails rdoc`
├── docs  # Documentation additionnelle concernant le projet
├── gpg  # Clefs de chiffrement GPG
├── kube  # Fichiers relatifs à k8s
├── lib  # Code de l'application non spécifique à Rails
│   ├── assets
│   ├── inuit  # Fonctions utilitaires pour l'interface utilisateur
│   ├── qualys  # Client Ruby pour communiquer avec l'API HTTP Qualys
│   ├── qualys_wa  # Client Ruby pour communiquer avec l'API HTTP Qualys WA
│   ├── sellsy  # Client Ruby pour communiquer avec l'API HTTP Sellsy
│   ├── tasks  # Commandes additionnelles
│   └── templates
├── log  # Fichiers de log
├── node_modules  # Fichiers générés par la compilation npm
├── public  # Dossier contenant les fichiers publics exposés par le serveur web
├── saml  # Certificats SAML
├── storage  # Répertoire de stockage
├── test  # Tests en tout genre
│   ├── controllers  # Tests des contrôleurs
│   ├── decorators  # Tests des décorateurs
│   ├── fixtures  # Données de tests utilisées pour initialiser la BDD
│   ├── helpers  # Tests des fonctions utilitaires
│   ├── integration  # Tests d'intégration
│   ├── jobs  # Tests des tâches de fond
│   ├── mailers  # Tests des mail
│   ├── models  # Tests des modèles
│   └── system  # Tests système (utilisation du site via un navigateur Web)
├── tmp  # Fichiers temporaires gérés par Rails
└── vendor  # Dépendances
    └── prawn-graph  # Version patchée de prawn-graph
```
