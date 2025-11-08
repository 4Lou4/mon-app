# 🚀 Guide de Lancement du Pipeline Jenkins

## Étape 1: Accéder à Jenkins

1. Ouvrir votre navigateur sur: **http://localhost:9090**

2. Si c'est la première connexion, récupérer le mot de passe :
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

3. Copier le mot de passe et le coller dans Jenkins

4. Installer les **plugins recommandés**

5. Créer un compte admin

## Étape 2: Créer les Credentials Docker Hub

1. Dans Jenkins, aller à: **Manage Jenkins** → **Manage Credentials**

2. Cliquer sur **(global)**

3. Cliquer sur **Add Credentials**

4. Remplir:
   - **Kind**: `Username with password`
   - **Scope**: `Global`
   - **Username**: `louaymejri`
   - **Password**: [Votre mot de passe/token Docker Hub]
   - **ID**: `dockerhub-creds`
   - **Description**: `Docker Hub Credentials`

5. Cliquer sur **Create**

## Étape 3: Créer le Job Pipeline

1. Sur la page d'accueil Jenkins, cliquer sur **New Item** (ou **Nouveau Item**)

2. Remplir:
   - **Name**: `mon-app-pipeline`
   - **Type**: Sélectionner **Pipeline**
   - Cliquer sur **OK**

3. Configuration du Pipeline:

   ### Section General
   - ☑ Cocher **GitHub project**
   - **Project url**: `https://github.com/4Lou4/mon-app/`

   ### Section Build Triggers (Optionnel)
   - ☑ **Poll SCM**: `H/5 * * * *` (vérifier toutes les 5 minutes)

   ### Section Pipeline
   - **Definition**: Sélectionner `Pipeline script from SCM`
   - **SCM**: Sélectionner `Git`
   - **Repository URL**: `https://github.com/4Lou4/mon-app.git`
   - **Credentials**: Laisser à `- none -` (repo public)
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile`

4. Cliquer sur **Save** (ou **Enregistrer**)

## Étape 4: Lancer le Premier Build

1. Sur la page du job `mon-app-pipeline`, cliquer sur **Build Now**

2. Un nouveau build #1 apparaîtra dans **Build History**

3. Cliquer sur **#1** puis **Console Output** pour voir les logs en direct

### Ce qui va se passer :

#### ✅ Stage 1: Clone
- Jenkins clone le repository GitHub

#### ✅ Stage 2: Build Docker Image
- Construction de l'image `louaymejri/mon-app:1`
- Tag `louaymejri/mon-app:latest`

#### ✅ Stage 3: Push Image
- Connexion à Docker Hub
- Push de l'image avec le numéro de build
- Push du tag latest

#### ✅ Stage 4: Update Deployment File
- Mise à jour de `deployment.yaml` avec la nouvelle image

#### ⚠️  Stage 5: Deploy to Kubernetes
- Le stage affichera un message pour déploiement manuel
- **VOUS DEVREZ** exécuter manuellement sur votre terminal:

```bash
cd /home/louay/tp3
./deploy-k8s.sh deployment.yaml service.yaml
```

## Étape 5: Déploiement Manuel sur Kubernetes

Une fois le pipeline terminé, ouvrez un terminal et exécutez:

```bash
# Aller dans le répertoire du projet
cd /home/louay/tp3

# Pull des derniers changements (avec le deployment.yaml mis à jour)
git pull

# Exécuter le script de déploiement
./deploy-k8s.sh deployment.yaml service.yaml
```

Ou manuellement:

```bash
cd /home/louay/tp3
git pull
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/mon-app-deployment
kubectl get pods -l app=mon-app
kubectl get svc mon-app-service
```

## Étape 6: Vérifier l'Application

```bash
# Voir l'état des pods
kubectl get pods -l app=mon-app

# Voir le service
kubectl get svc mon-app-service

# Tester l'application
curl http://192.168.49.2:30080

# Ou via le script de vérification
./verify-deployment.sh
```

## 🔧 Dépannage

### Erreur: "dockerhub-creds not found"
- Vérifiez que vous avez bien créé les credentials avec l'ID exact: `dockerhub-creds`

### Erreur: "permission denied while trying to connect to Docker"
```bash
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

### Le build reste bloqué
- Vérifiez les logs: cliquez sur le build puis **Console Output**
- Vérifiez que Docker Hub credentials sont corrects

### kubectl ne fonctionne pas dans Jenkins
- C'est normal ! Utilisez le script `deploy-k8s.sh` sur l'hôte après le build

## 📊 Workflow Complet

```
1. Modifier le code
2. git push vers GitHub
3. Jenkins détecte le changement (ou Build Now manuel)
4. ✅ Jenkins clone le repo
5. ✅ Jenkins build l'image Docker
6. ✅ Jenkins push sur Docker Hub
7. ✅ Jenkins met à jour deployment.yaml
8. ⚠️  Vous exécutez: ./deploy-k8s.sh
9. ✅ Application déployée sur Kubernetes
10. ✅ Tester: http://192.168.49.2:30080
```

## 🎯 Commandes Rapides

```bash
# Voir les logs Jenkins en temps réel
docker logs -f jenkins

# Accéder au conteneur Jenkins
docker exec -it jenkins bash

# Voir les images Docker
docker images | grep louaymejri

# Voir l'état Kubernetes
kubectl get all -l app=mon-app

# Redéployer une version spécifique
kubectl set image deployment/mon-app-deployment mon-app=louaymejri/mon-app:5
kubectl rollout status deployment/mon-app-deployment
```

## 📝 Notes Importantes

1. **Le pipeline build et push fonctionnent parfaitement** ✅
2. **Le déploiement Kubernetes nécessite une action manuelle** ⚠️
3. **Chaque build crée une nouvelle image avec un numéro unique**
4. **Les anciennes images restent sur Docker Hub pour rollback**

## 🚀 Prêt !

Vous pouvez maintenant:
1. Accéder à Jenkins: http://localhost:9090
2. Créer le job pipeline
3. Lancer le build
4. Déployer sur Kubernetes

Bonne chance avec votre TP3 ! 🎉
