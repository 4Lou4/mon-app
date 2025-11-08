# TP3 - Application Minimale avec Jenkins CI/CD et Kubernetes

Application Node.js simple déployée automatiquement avec Jenkins et Kubernetes.

## Structure du Projet

```
tp3/
├── Dockerfile              # Image Docker de l'application
├── index.js                # Application Node.js simple
├── package.json            # Dépendances Node.js
├── deployment.yaml         # Déploiement Kubernetes
├── service.yaml            # Service Kubernetes
├── Jenkinsfile             # Pipeline CI/CD Jenkins
└── README.md               # Ce fichier
```

## Prérequis

### 1. Docker Hub
- Créer un compte sur [Docker Hub](https://hub.docker.com)
- Créer un repository (ex: `ton-username/mon-app`)

### 2. Jenkins
- Jenkins installé et accessible
- Plugins nécessaires:
  - Docker Pipeline
  - Kubernetes CLI
  - Git

### 3. Kubernetes
- Cluster Kubernetes opérationnel (Minikube, k3s, ou autre)
- `kubectl` configuré et accessible depuis Jenkins

## Configuration

### 1. Modifier le Jenkinsfile

Dans `Jenkinsfile`, remplace:
```groovy
IMAGE = "TON_DOCKERHUB/mon-app"  // Ton username Docker Hub
git url: 'https://github.com/<ton-utilisateur>/mon-app.git'  // Ton repo GitHub
```

### 2. Créer les credentials dans Jenkins

1. Aller dans **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. Ajouter une credential:
   - **ID**: `dockerhub-creds`
   - **Type**: Username with password
   - **Username**: Ton username Docker Hub
   - **Password**: Ton token/password Docker Hub

### 3. Configurer l'accès Docker et Kubernetes dans Jenkins

**Option A: Jenkins sur l'hôte**
```bash
# Ajouter l'utilisateur jenkins au groupe docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**Option B: Jenkins dans un conteneur**
```yaml
# docker-compose.yml pour Jenkins
version: '3'
services:
  jenkins:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/.kube:/root/.kube:ro
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock

volumes:
  jenkins_home:
```

### 4. Installer kubectl dans Jenkins

Si Jenkins n'a pas `kubectl`:
```bash
# Sur le serveur Jenkins ou dans le conteneur
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## Déploiement

### 1. Créer le Job Jenkins

1. **New Item** → **Pipeline**
2. Nom: `mon-app-pipeline`
3. Dans **Pipeline**:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: URL de ton repo
   - **Branch**: `main` ou `master`
   - **Script Path**: `Jenkinsfile`

### 2. Lancer le Pipeline

1. Cliquer sur **Build Now**
2. Suivre les logs dans **Console Output**

### 3. Vérifier le Déploiement

```bash
# Vérifier les pods
kubectl get pods -l app=mon-app

# Vérifier le service
kubectl get svc mon-app-service

# Voir les détails d'un pod
kubectl describe pod <pod-name>

# Voir les logs
kubectl logs <pod-name>

# Tester l'application
# Si sur Minikube:
minikube service mon-app-service

# Ou via NodePort:
curl http://<node-ip>:30080
```

## Test Local

### Sans Docker
```bash
npm install
node index.js
# Ouvrir http://localhost:80
```

### Avec Docker
```bash
docker build -t mon-app:test .
docker run -p 8080:80 mon-app:test
# Ouvrir http://localhost:8080
```

### Avec Kubernetes (local)
```bash
# Construire l'image
docker build -t mon-app:v1 .

# Tag pour Docker Hub (ou registry local)
docker tag mon-app:v1 ton-dockerhub/mon-app:v1

# Push
docker push ton-dockerhub/mon-app:v1

# Modifier deployment.yaml avec la bonne image
sed -i 's|ton-dockerhub/mon-app:latest|ton-dockerhub/mon-app:v1|g' deployment.yaml

# Déployer
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Vérifier
kubectl get pods
kubectl get svc
```

## Dépannage

### Problème: Jenkins ne peut pas accéder à Docker
```bash
# Vérifier les permissions
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Problème: kubectl non trouvé dans Jenkins
```bash
# Installer kubectl dans le conteneur Jenkins
docker exec -it jenkins bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
```

### Problème: ImagePullBackOff dans Kubernetes
```bash
# Vérifier que l'image existe sur Docker Hub
docker pull ton-dockerhub/mon-app:latest

# Vérifier les secrets si repo privé
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<username> \
  --docker-password=<password>
```

### Problème: Pods en CrashLoopBackOff
```bash
# Voir les logs
kubectl logs <pod-name>

# Voir les événements
kubectl describe pod <pod-name>
```

## Commandes Utiles

```bash
# Redémarrer un déploiement
kubectl rollout restart deployment/mon-app-deployment

# Voir l'historique des déploiements
kubectl rollout history deployment/mon-app-deployment

# Rollback vers la version précédente
kubectl rollout undo deployment/mon-app-deployment

# Scaler le déploiement
kubectl scale deployment/mon-app-deployment --replicas=3

# Supprimer le déploiement
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```

## Architecture

```
┌─────────────┐
│   GitHub    │
│  Repository │
└──────┬──────┘
       │
       │ Webhook/Poll
       ▼
┌─────────────┐
│   Jenkins   │
│   Pipeline  │
└──────┬──────┘
       │
       ├── Build Docker Image
       │
       ├── Push to Docker Hub
       │
       └── Deploy to Kubernetes
              │
              ▼
       ┌─────────────┐
       │ Kubernetes  │
       │   Cluster   │
       └──────┬──────┘
              │
              ├── Deployment (2 replicas)
              │
              └── Service (NodePort 30080)
```

## Notes

- L'application écoute sur le port 80
- Le service expose le port 30080 (NodePort)
- 2 replicas sont configurés pour la haute disponibilité
- Les health checks sont configurés (liveness & readiness probes)
- L'image Docker est basée sur Node.js 18 Alpine (légère)

## Auteur

TP3 - DevOps avec Jenkins et Kubernetes
