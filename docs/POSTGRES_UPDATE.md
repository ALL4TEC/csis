# Updating postgres

## First, shut down the db (scale replicas to 0 || delete deployment)

> Create new pod

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: postgres-upgrade
spec:
  containers:
  - name: postgres-upgrade
    args:
    - bash
    stdin: true
    tty: true
    image: tianon/postgres-upgrade:11-to-12 # Adapt to the versions you are using
    volumeMounts:
    - name: db-storage
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: db-storage
    persistentVolumeClaim:
      claimName: db-pv-claim
```

> Connect to the new pod (you can use vscode extension)

```bash
kubectl exec -it $(kubectl get po -o name | grep postgres-upgrade) -- sh
```

> Change ownership and rights of directories ( /!\ Vérifier si nécessaire)

```bash
chown -R postgres /var/lib/postgresql/* ?
chmod -R 700 /var/lib/postgresql/* ?
```

> Use postgres user, pg_upgrade refuses to run as root

```bash
gosu postgres bash # Custom command
```

> Init new postgres data folder

```bash
# Creating the new folder inside the previous because it needs to be on the same partition for pg_upgrade --link option to work
PGDATA=/var/lib/postgresql/data/new initdb
```

> Allow local access to old database ( /!\ Vérifier si nécessaire)

```bash
# Nécessite de sauvegarder le précédent pg_hba.conf || pas nécessaire de faire la copie
cp /var/lib/postgresql/data/new/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
```

> Run pg_upgrade

```bash
cd /tmp
pg_upgrade -d /var/lib/postgresql/data -D /var/lib/postgresql/data/new --link
```

> Replace old folder

```bash
GLOBIGNORE=/var/lib/postgresql/data/new rm -fr /var/lib/postgresql/data/*
mv /var/lib/postgresql/data/new/* /var/lib/postgresql/data
```

> Delete pod

```bash
kubectl delete pod postgres-upgrade
```

> Scale DB back up