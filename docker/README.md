# **HOW TO DOCKER**

## **Build an image**

> __With docker:__

```bash
docker build -t <tagname> . -f <dockerfile>
```

> __With docker-compose:__

```bash
docker-compose -f <docker-compose-file> <service_name>? build
```

## **Publish an image on the registry**

> __Choose tagname__:

`registry.gitlab.com/mycompany/csis-dev/csis/csis_app:*<csis_version>*:*<branch_name>*` where branch_name among *develop* or *master*

* On ne publiera automatiquement depuis les builds gitlab que les images provenant des branches *develop* ou *master* pour instancier respectivement la *preprod* et la *prod*
* __csis_version__ est la version de l'application, récupérable avec la commande suivante:

```bash
rake csis:version
```

> __Build__:

```bash
docker build -t <tagname> . -f <dockerfile>
```

> __Login to registry__:

```bash
docker login registry.gitlab.com
```

> __Push__:

```bash
docker push <tagname>
```

## **Composition Docker**

> [Documentation officielle](https://docs.docker.com/compose/compose-file/)

Sont présents dans l'application des fichiers **docker-compose-*** dédiés à chaque **environnement*** permettant de tester localement chaque env. L'environnement *staging* est un environnement temporaire permettant de préparer la dockerisation de l'application (certaines variables d'environnement actuellement gérées par clevercloud changent légèrement).

Voici la liste des différents environnements disponibles et la composition minimale requise. A noter que le contenu de ces fichiers est modifiable à tout moment au besoin (Plusieurs instances en local, ajout de containers etc...).

> __Légende__:

* &check; `=> Mandatory`
* &cross; `=> Not mandatory`

| Environment | Postgresql | Redis     | Csis      | PgAdmin*     | Resque*      | Nginx      |
| :---------- | :--------- | :-------- | :-------- | :-----------| :---------- | :----------|
| **Development**| &check; | &check; | &check; | &cross; | &cross; | &cross; |
| **Tests**      | &check; | &check; | &check; | &cross; | &cross; | &cross; |
| **Staging**    | &check; | &check; | &check; | &check; | &check; | &check; |
| **Production** | &check; | &check; | &check; | &check; | &check; | &check; |

* ***PgAdmin** container could be deployed to manage multiple CSIS instances.
* ***Resque** peut devenir nécessaire en environnement de développement si on souhaite tester un job...

Il pourra être intéressant de regarder les redis-cli-gui. Redsmine est gratuit jusqu'à 100000 keys.

## **Used images**

* __Postgresql__: [*postgres:alpine*](https://hub.docker.com/_/postgres) contains latest postgresql version on light linux OS
* __PgAdmin__: [*dpage/pgadmin4*](https://hub.docker.com/r/dpage/pgadmin4) contains latest pgAdmin version, enabling to configure [__pg_dump crons__](https://www.pgadmin.org/docs/pgadmin4/dev/pgagent_jobs.html) etc...
* __Redis__: [*redis:alpine*](https://hub.docker.com/_/redis)
* __Resque__: Based on csis image, it only launches the queue workers
* __Nginx__: Reverse-proxy, WAF and load-balancer. Custom image based on [*nginx*](https://hub.docker.com/_/nginx)

## [**Kubernetes**](../kube/README.md)

[What is it?](https://cloud.google.com/kubernetes-engine/kubernetes-comic/)

### __Installation__

Kubernetes is automatically installed with docker on linux systems but needs to be enabled in configuration.

### __Dashboard__

[Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) is a docker image enabling to manage all nodes.

### [__Minikube__](../kube/LOCAL_PREPROD.md)

[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is a tool to use kubernetes locally.

### __Kompose__

* [Kompose-github](https://github.com/kubernetes/kompose)
* [Kompose-io](<http://kompose.io/>)
