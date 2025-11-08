# Configuration Jenkins pour TP3

## 📋 Prérequis Jenkins

Avant de créer le job, assurez-vous que Jenkins a :

### 1. Accès à Docker
```bash
# Ajouter jenkins au groupe docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 2. Accès à kubectl
```bash
# Copier la config kubectl pour Jenkins
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

### 3. Credentials Docker Hub
- Aller dans **Jenkins** → **Manage Jenkins** → **Manage Credentials**
- Cliquer sur **(global)** → **Add Credentials**
- **Kind**: Username with password
- **Scope**: Global
- **Username**: `louaymejri`
- **Password**: [Votre token/password Docker Hub]
- **ID**: `dockerhub-creds`
- **Description**: Docker Hub Credentials
- Cliquer sur **Create**

## 🚀 Créer le Job Pipeline

### Étape 1: Nouveau Job
1. Aller sur Jenkins: http://localhost:8080
2. Cliquer sur **"New Item"** (ou **"Nouveau Item"**)
3. Nom du job: `mon-app-pipeline`
4. Sélectionner **"Pipeline"**
5. Cliquer sur **"OK"**

### Étape 2: Configuration du Pipeline
1. Dans **General**:
   - ☑ GitHub project
   - Project url: `https://github.com/4Lou4/mon-app/`

2. Dans **Build Triggers** (optionnel):
   - ☑ GitHub hook trigger for GITScm polling (si webhook configuré)
   - OU ☑ Poll SCM: `H/5 * * * *` (vérifier toutes les 5 minutes)

3. Dans **Pipeline**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/4Lou4/mon-app.git`
   - **Credentials**: Laisser vide (si repo public)
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile`

4. Cliquer sur **"Save"** (ou **"Enregistrer"**)

### Étape 3: Lancer le Pipeline
1. Sur la page du job, cliquer sur **"Build Now"**
2. Un build #1 apparaîtra dans **Build History**
3. Cliquer sur **#1** puis **"Console Output"** pour voir les logs

## 🔍 Vérification du Déploiement

Une fois le pipeline terminé avec succès, vérifiez le déploiement sur Kubernetes.

### Vérifier les Pods
```bash
# Voir tous les pods de l'application
kubectl get pods -l app=mon-app

# Sortie attendue:
# NAME                                   READY   STATUS    RESTARTS   AGE
# mon-app-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
# mon-app-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

### Vérifier le Service
```bash
# Voir le service
kubectl get svc mon-app-service

# Sortie attendue:
# NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# mon-app-service   NodePort   10.xx.xxx.xxx   <none>        80:30080/TCP   2m
```

### Voir les détails d'un Pod
```bash
# Lister les pods et copier un nom
kubectl get pods -l app=mon-app

# Voir les détails (remplacer <pod-name>)
kubectl describe pod <pod-name>
```

### Voir les logs d'un Pod
```bash
# Logs d'un pod spécifique
kubectl logs <pod-name>

# Logs de tous les pods de l'app
kubectl logs -l app=mon-app

# Suivre les logs en temps réel
kubectl logs -f <pod-name>
```

### Tester l'Application
```bash
# Si sur Minikube, obtenir l'URL
minikube service mon-app-service --url

# Ou accéder via NodePort
kubectl get nodes -o wide  # Noter l'IP du node
curl http://<node-ip>:30080

# Si sur Minikube:
curl http://$(minikube ip):30080
```

## ⚠️ Dépannage

### Problème: ImagePullBackOff
```bash
# Vérifier les événements
kubectl describe pod <pod-name>

# Vérifier que l'image existe sur Docker Hub
docker pull louaymejri/mon-app:latest
```

### Problème: CrashLoopBackOff
```bash
# Voir les logs du pod
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Logs du conteneur précédent
```

### Problème: Pending
```bash
# Vérifier les ressources du cluster
kubectl describe node
kubectl top node
```

### Problème: Jenkins ne peut pas se connecter à Docker
```bash
# Vérifier les permissions
docker ps
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Problème: Jenkins ne trouve pas kubectl
```bash
# Dans le serveur Jenkins
which kubectl
sudo cp /usr/local/bin/kubectl /usr/bin/kubectl
```

## 📊 Commandes Utiles Kubernetes

```bash
# Voir tous les déploiements
kubectl get deployments

# Voir l'état du rollout
kubectl rollout status deployment/mon-app-deployment

# Redémarrer le déploiement
kubectl rollout restart deployment/mon-app-deployment

# Voir l'historique des déploiements
kubectl rollout history deployment/mon-app-deployment

# Rollback vers la version précédente
kubectl rollout undo deployment/mon-app-deployment

# Scaler le déploiement
kubectl scale deployment/mon-app-deployment --replicas=3

# Supprimer le déploiement
kubectl delete deployment mon-app-deployment
kubectl delete service mon-app-service

# Ou tout supprimer via les fichiers
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```

## 🔄 Pipeline CI/CD - Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                     1. Push Code to GitHub                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              2. Jenkins détecte le changement               │
│                 (webhook ou polling)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  3. Stage: Clone Repository                 │
│           git clone https://github.com/4Lou4/mon-app        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              4. Stage: Build Docker Image                   │
│        docker build -t louaymejri/mon-app:BUILD_NUM         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│             5. Stage: Push to Docker Hub                    │
│           docker push louaymejri/mon-app:BUILD_NUM          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            6. Stage: Deploy to Kubernetes                   │
│         sed -i 's|image|new-image|' deployment.yaml         │
│              kubectl apply -f deployment.yaml               │
│               kubectl apply -f service.yaml                 │
│    kubectl rollout status deployment/mon-app-deployment     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  ✅ Déploiement Réussi                      │
│            Application accessible sur port 30080            │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Checklist Finale

- [ ] Docker Hub credentials créées dans Jenkins (`dockerhub-creds`)
- [ ] Jenkins a accès à Docker (`docker ps` fonctionne)
- [ ] Jenkins a accès à kubectl (fichier kubeconfig copié)
- [ ] Cluster Kubernetes opérationnel (`kubectl cluster-info`)
- [ ] Job Pipeline créé dans Jenkins
- [ ] Repository GitHub configuré correctement
- [ ] Jenkinsfile présent dans le repo
- [ ] Premier build lancé avec succès
- [ ] Pods en état `Running` sur Kubernetes
- [ ] Service accessible via NodePort
- [ ] Application répond sur http://<node-ip>:30080

## 📝 Notes

- Le pipeline utilise le numéro de build Jenkins comme tag Docker
- Chaque build crée une nouvelle image: `louaymejri/mon-app:1`, `louaymejri/mon-app:2`, etc.
- Le déploiement Kubernetes est mis à jour automatiquement avec la nouvelle image
- Les anciennes images restent sur Docker Hub pour rollback si nécessaire

Bonne chance avec votre TP3 ! 🚀
