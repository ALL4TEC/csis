# Informations

## 1. Jobs

> Gestion des tâches 'db:migrate', 'db:seed', 'assets:precompile', ...

### Problèmes

* __Quand__

```html
Certaines tâches doivent être run au déploiment initial, d'autres à chaque déploiement.

Impossible de le faire au déploiement de pods, la base ne serait pas accessible.
```

* __Downtime__

```html
Le déploiment d'un pod ainsi qu'une migration prennent du temps.

L'ancien code peut tourner sur un schéma de base nouveau.

Le nouveau code peut tourner sur un ancien schéma de base.
```

### Solutions

#### Comment exécuter

* __kubectl__

```bash
kubectl exec -it pods/nom_du_pod -- rails db:migrate
```

* __Kubernetes Jobs__

> A la complétion du job, supprimer le pod pour libérer l'espace et pouvoir le relancer plus tard.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: migrate
          image: username/kubernetes-rails-example:latest
          command: ['rails']
          args: ['db:migrate']
          env: …
```

#### Choix d'une stratégie

* __Downtime__

```html
Scale les réplicas à 0, faire les migrations et rescale.

    Pour : Simple, pas d'erreurs (mauvais schéma pour mauvais code).

    Contre : Site down qques minutes.

Déployer le code puis faire la migration à partir d'un pod.

    Pour : Pas de site down, déploiement simple.

    Contre : Difficile de garder le code compatible avec l'ancien schéma.

Faire la migration puis déployer le code.

    Pour : Technique utilisée par les outils de CI/CD, fiable.

    Contre : Nécessaire d'avoir des migrations compatibles avec le nouveau et l'ancien code, utilisation de tag pour les images pour ne pas avoir un redéploiement auto qui pull la nouvelle image pendant les migrations.
```

### CI/CD

> Création d'un script de déploiement, l'image est build lors du merge sur la branche déploiement.

```bash
#!/bin/sh -ex
export KUBECONFIG=path/to/kubeconfig.yml

kubectl create -f kube/jobs/csis-db-migrate-job.yml
kubectl wait --for=condition=complete --timeout=600s job/csis-db-migrate-job

kubectl delete job csis-db-migrate-job

kubectl rollout restart deployment/csis-app-deployment
kubectl rollout restart deployment/csis-queue-deployment
```

>Si la conf kubernetes est modifiée, ne pas oublier de l'apply. (l'ajouter au script ?)

___

Kubernetes-deploy : Verbose lors du déploiement, chiffrement des secrets, lancement des tâches.
<https://github.com/Shopify/kubernetes-deploy>

## 2. Logs

> Les pods ont leur propres logs : 'kubectl logs nom_du_pod'.

### Gestion

> Laisser Kubernetes et Docker gérer les logs via stdout.

```yaml
env:
  - name: RAILS_LOG_TO_STDOUT
    value: enabled
```

### Persistence

> Utilisation d'un service de logging centralisé

* Rails écrit les logs sur stdout,
* K8s les stocke sur les nodes,
* Le pod Fluentd (DaemonSet) de chaque node les envoie au service centralisé,
* Les logs sont disponibles sur le service pour lecture, visualisation et recherche.

#### Installation de Fluentd

> <https://docs.ovh.com/fr/logs-data-platform/kubernetes-fluent-bit/>

```bash
kubectl create secret generic logzio-secrets --from-literal=logzio_token='MY_LOGZIO_TOKEN' --from-literal=logzio_url='MY_LOGZIO_URL' -n kube-system

kubectl apply -f https://raw.githubusercontent.com/collimarco/logzio-k8s/use_k8s_secrets/logzio-daemonset-rbc.yaml
```

## 3. Security

> kube-hunter

```bash
kubectl apply -f job.yaml (nom à changer si ajouté au source)
```

> kube-bench

```bash
kubectl apply -f job-iks.yaml (nom à changer si ajouté au source)
```

### RBAC

> /!\ impossible d'utiliser l'oidc et de changer les kube-apiserver flags pour le moment ...

```html
Gestion des droits et authorisations.

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users. All resources are modeled API objects in Kubernetes, belonging to API Groups. These resources allow operations such as Create, Read, Update, and Delete (CRUD). RBAC is writing rules to allow or deny operations on resources by users, roles or groups.

Rules are operations which can act upon an API group.

Roles are a group of rules which affect, or scope, a single namespace

    ClusterRoles have a scope of the entire cluster.

Each operation can act upon one of three subjects

    User Accounts
    Service Accounts
    Groups

Here is a summary of the RBAC process:

    Determine or create namespace
    Create certificate credentials for user
    Set the credentials for the user to the namespace using a context
    Create a role for the expected task set
    Bind the user to the role
    Verify the user has limited access.

RBAC Manager : Simplifie conf et update auto
https://github.com/FairwindsOps/rbac-manager

RBACSync : Synchro RoleBinging et ClusterRoleBinding
https://github.com/cruise-automation/rbacsync
```

> Test authorization

```yaml
kubectl auth can-i create deployments --as dev
```

### Namespaces

```html
Permet de séparer les outils de l'infra par exemple.
Simplifie également l'utilisation de RBAC.
```

### Containers

```yaml
spec:
  securityContext:
```

> Ne pas run as root ?

```yaml
    runAsUser: 1024
```

> Désactiver les commandes linux enabled par défaut

```yaml
      capabilities:
        drop:
          - ALL
```

Liste des commandes : <https://github.com/moby/moby/blob/master/oci/defaults.go#L14-L30>

> Rendre les fichiers read-only

```yaml
    readOnlyRootFilesystem: true
```

> Désactiver su

```yaml
    allowPrivilegeEscalation: false
```

> Scanner les containers pour vulns

```yaml
Anchore : https://anchore.com/
Clair : https://github.com/coreos/clair
```

> Analyse des yaml + scoring

```bash
# kubesec.io, installable en local, utiliser en CI ?

https://github.com/controlplaneio/kubectl-kubesec

scan deployment csis-app
```

> Ajouter des network policies

Contrôles des accès en entrée et sortie des pods.

> Whitelist IPs

```html
- N'autoriser que les IPs du bureau à accéder à kubelet, etc ...
- Ajouter des groupes de sécu avec des règles de traffic.
- Ajouter qqchose pour Lilian en télétravail ou Pierre en prez ?
```

``` yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: whitelist
  annotations:
    ingress.kubernetes.io/whitelist-source-range: "1.1.1.1/24"
```

> Chiffrement des secrets

```html
Kubernetes secrets : encodés en base64 -> pas commitable (même si pas forcément utile pour nous), mais facilement lisibles.

Besoin de suivi des modifications (Git).

Possibilité d'utiliser le secret comme variable d'environnement, ou de la monter dans un fichier.

Permissions sur les secrets : get and set, pas de 'get mais que chiffré'.

Solution : Kamus permet un chiffrement asymétrique.

Repo : https://kamus.soluto.io/docs/user/install/
Article : https://itnext.io/can-kubernetes-keep-a-secret-it-all-depends-what-tool-youre-using-498e5dee9c25
```

## 4. Env Variables

> Possibilité d'utiliser les configmaps pour éviter une redondance des variables d'environnement

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env
data:
  RAILS_ENV: production
  RAILS_LOG_TO_STDOUT: enabled
  RAILS_SERVE_STATIC_FILES: enabled
  DATABASE_URL: postgresql://example.com/mydb
  REDIS_URL: redis://redis.default.svc.cluster.local:6379/
```

> Ajouter au déploiement

```yaml
envFrom:
- configMapRef:
    name: env
```
