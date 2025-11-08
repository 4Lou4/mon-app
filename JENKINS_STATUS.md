# ✅ État de Configuration Jenkins

## Jenkins est opérationnel ! 🎉

### Configuration Actuelle
- **URL Jenkins** : http://localhost:9090
- **Docker** : ✅ Installé et fonctionnel dans Jenkins
- **kubectl** : ⚠️  Doit s'exécuter sur l'hôte (pas dans le conteneur)

### Accéder à Jenkins
1. Ouvrir http://localhost:9090 dans votre navigateur
2. Si c'est la première fois, récupérer le mot de passe :
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### ⚠️ Important pour le Pipeline

Le Jenkinsfile doit être modifié pour exécuter kubectl sur l'hôte plutôt que dans le conteneur Jenkins.

**Option 1: Utiliser `agent { label 'built-in' }` et installer Jenkins directement sur l'hôte**

**Option 2: Modifier le Jenkinsfile pour exécuter kubectl via docker exec**

Je vous recommande **d'utiliser Jenkins directement sur l'hôte** pour éviter les problèmes de réseau. Voici comment:

```bash
# Arrêter Jenkins Docker
docker stop jenkins

# Installer Jenkins sur l'hôte (Ubuntu/Debian)
sudo apt update
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y

# Donner accès Docker à Jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Jenkins sera sur http://localhost:8080
```

### Solution Alternative (Garder Jenkins Docker)

Modifiez le stage Deploy dans le Jenkinsfile :

```groovy
stage('Deploy to Kubernetes') {
  steps {
    echo "Déploiement sur Kubernetes..."
    script {
      // Mettre à jour l'image dans deployment.yaml
      sh """
        sed -i 's|louaymejri/mon-app:latest|${IMAGE}:${TAG}|g' deployment.yaml || true
      """
      
      // Exécuter kubectl sur l'hôte via docker exec
      sh "docker cp deployment.yaml minikube:/tmp/deployment.yaml"
      sh "docker exec minikube kubectl apply -f /tmp/deployment.yaml --kubeconfig=/var/lib/minikube/kubeconfig"
      
      sh "docker cp service.yaml minikube:/tmp/service.yaml"
      sh "docker exec minikube kubectl apply -f /tmp/service.yaml --kubeconfig=/var/lib/minikube/kubeconfig"
    }
  }
}
```

### Vérification Rapide

```bash
# Vérifier que Jenkins Docker tourne
docker ps | grep jenkins

# Vérifier que Docker fonctionne dans Jenkins
docker exec jenkins docker ps

# Tester l'application Kubernetes
curl http://192.168.49.2:30080
```

### Prochaines Étapes

1. ✅ Accéder à Jenkins : http://localhost:9090
2. ✅ Installer les plugins recommandés
3. ✅ Créer les credentials Docker Hub (ID: `dockerhub-creds`)
4. ✅ Créer un job Pipeline
5. ✅ Pointer vers votre repo GitHub : https://github.com/4Lou4/mon-app
6. ✅ Lancer le build (les stages Docker build/push fonctionneront)
7. ⚠️  Pour le déploiement Kubernetes, voir les solutions ci-dessus

Voulez-vous que je vous aide à installer Jenkins sur l'hôte ou à modifier le Jenkinsfile pour la solution Docker ?
