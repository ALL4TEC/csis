# OVH Cluster Configuration

## Dépendances

```bash
sudo apt install kubectl
sudo apt install helm
```

> Export the kubeconfig file from OVH for the cluster into environment variable :

```bash
export KUBECONFIG=kubeconfig.yml
```

> Check if you are connected to the cluster on OVH

```bash
kubectl cluster-info
```

> Deploy the Kubernetes DashBoard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
```

> Create an admin ServiceAccount and RoleBinding to manage the dashboard

```bash
kubectl apply -f kube/RBAC/dashboard.yml
```

## Connect to the DASHBOARD

> Recover the Token for the admin to connect to the dashboard

```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user-token | awk '{print $1}')
```

> Run the proxy command to proxyfi the dashboard locally

```bash
kubectl proxy
```

> Access the dashboard through this URL

`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`

## Launch Csis instance

```bash
cd kube
kubectl apply -f volumes/
kubectl apply -f servicesaccount/
kubectl apply -f rolesbinding/
kubectl apply -f services/
kubectl apply -f deployment/
kubectl apply -f ingress/
helm install stable/nginx-ingress
```

## MEMO

> Restart pods

```bash
kubectl scale deployment csis-queue --replicas=0
kubectl scale deployment csis-queue --replicas=1
```

> Recuperer une ressource :

```bash
kubectl get <type de ressource> <nom de la ressource>
```

ex: `kubectl get pods csis-app`

> Editer une ressource :

```bash
kubectl edit <type de ressource> <nom de la ressource>
```

ex: `kubectl edit pods csis-app`

> Supprimer une ressource :

```bash
kubectl delete <type de ressource> <nom de la ressource>
```

ex: `kubectl delete pods csis-app`

> Pour faciliter les choses utiliser [Kubebox](https://github.com/astefanutti/kubebox)

```bash
kubebox
```
