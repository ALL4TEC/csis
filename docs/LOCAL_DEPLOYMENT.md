# TODO

* [x] Minikube basics
* [x] Pull images from gitlab registry
* [x] Setup OAuth to use prod credentials
* [x] Setup Nginx Ingress to route app and pgadmin
* [x] Setup HTTPS in staging
* [x] Setup QUEUE correctly
* [x] Add shared volume for assets
* [x] Setup nginx to serve assets (migrate and precompile on the fly)
* [.] Setup PGAdmin correctly (volume + server if possible) --> Docker mount servers.json as a folder instead of a file for pgadmin
* [?] Add volume for redis (Si possible)
* [.] Setup logs correctly (Syslog)
* [x] Verify cron jobs
* [x] Improve minikube capacities (crash lors de l'export d'un rapport, dû à kubernetes qui le considère buggé ?)
* [.] Make deploy a single step (script + yaml files) --> params pour script, que faire si maj des yaml ? ...
* [?] Take care of others ENV (docker-compose, minikube?) --> garder le fonctionnement habituel pour dev et test ? + rapide ?
* [.] GitLab automation (Image pushing, pulling, ...)
* [ ] DB backups
* [.] Secure everything
* [x] GPG in kubernetes

## Procedure to launch preprod locally

```bash
# Start Minikube
minikube start

# Start dashboard
minikube dashboard

# Create master key

kubectl create secret generic rails-secrets --from-literal=rails_master_key='example'

# Add it to the deployment

- name: RAILS_MASTER_KEY
  valueFrom:
    secretKeyRef:
      name: rails-secrets
      key: rails_master_key

# Set access to gitlab registry
# Has also been set in docker-compose-staging.yml
kubectl create secret --namespace=default \
                      docker-registry gitlab-registry \
                      --docker-server=myserver \
                      --docker-username=$dusername \
                      --docker-password=$dpassword \
                      --output yaml --dry-run | kubectl apply -n default -f -
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gitlab-registry"}]}'

# Create cluster
kompose up -f docker-compose-staging.yml

# OAuth setup
# Has also been set in console.developers.google.com__
echo "$(minikube ip) preprod.csis.eu" | sudo tee -a /etc/hosts

# Assets precompile + Migrate + Seed DB
kubectl exec -it csis-app-*-* -- rails assets:precompile ; rails db:migrate ; rails db:seed
```

## HTTPS

```bash
# Setup ingress
minikube addons enable ingress

# Create key
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout tls.key -out tls.crt -subj "/CN=csis.eu" -days 365

# Configure hosts (csis -> preprod, possible à terme mais nécessite changement conf creds google)
echo "$(minikube ip) csis.eu pgadmin.csis.eu" | sudo tee -a /etc/hosts

# Create secret
kubectl create secret tls csis-tls --cert=tls.crt --key=tls.key
```

```yaml
cat << EOF | kubectl create -f -
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: certificate@csis.eu
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - selector: {}
      http01:
        ingress:
          class: nginx
EOF

cat << EOF | kubectl create -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: csis-preprod
spec:
  secretName: csis-preprod-tls
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging
  dnsNames:
  - preprod.csis.app
  - csis-pgadmin-preprod.csis.eu
  acme:
    config:
    - http01:
        ingressClass: nginx
      domains:
      - preprod.csis.app
      - csis-pgadmin-preprod.csis.eu
EOF
```

## Ingress configuration

```yaml
spec:
  rules:
  - host: csis.eu
    http:
      paths:
      - backend:
          serviceName: csis-web
          servicePort: 8002
  - host: pgadmin.csis.eu
    http:
      paths:
      - backend:
          serviceName: csis-db-admin
          servicePort: 8081
  tls:
  - hosts:
    - csis.eu
    - pgadmin.csis.eu
    secretName: csis-tls
```

## MEMO

> Get service URL

```bash
minikube service csis-web --url
```

> Use local repo

```bash
eval $(minikube docker-env)
```

> Use vi in a pod

```bash
export TERM=linux
```

> Copy in a pod

```bash
kubectl cp default/csis-app-67c8c6d87-8vq64:/var/www/csis/config/credentials.yml.enc creds.txt.enc
```

> Show nginx logs

```bash
kubectl logs -n kube-system nginx-ingress-controller-*-*
```

> Restart PUMA

```bash
pumactl -p 1 restart
```

> Add IP Address to eth2 in minikube VM

Add with the GUI new interface eth2 with Bridge Adapter
then go in vm with minikube ssh

```bash
ifconfig eth2 add 10.23.0.100 netmask 255.255.255.0 up # <- to expose the VM
```

> Import servers configuration (need to be in csis folder)

```bash
cd csis
kubectl cp /home/preprod/csis/server.json default/csis-db-admin-xxx:/pgadmin4/server.json
kubectl exec -it csis-db-admin-xxxxxxxx -- python setup.py --load-servers server.json
```
