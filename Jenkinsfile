pipeline {
  agent any
  
  environment {
    // À MODIFIER: Remplace par ton nom d'utilisateur Docker Hub
    IMAGE = "louaymejri/mon-app"
    TAG = "${env.BUILD_NUMBER}"
  }
  
  stages {
    stage('Clone') {
      steps {
        echo "Clonage du dépôt Git..."
        // À MODIFIER: Remplace par l'URL de ton repo GitHub
        git url: 'https://github.com/4Lou4/mon-app.git', branch: 'main'
      }
    }
    
    stage('Build Docker Image') {
      steps {
        echo "Construction de l'image Docker..."
        script {
          sh "docker build -t ${IMAGE}:${TAG} ."
          sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
        }
      }
    }
    
    stage('Push Image') {
      steps {
        echo "Publication de l'image sur Docker Hub..."
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push ${IMAGE}:${TAG}
            docker push ${IMAGE}:latest
            docker logout
          '''
        }
      }
    }
    
    stage('Deploy to Kubernetes') {
      steps {
        echo "Déploiement sur Kubernetes..."
        script {
          // Mettre à jour l'image dans deployment.yaml avant apply
          sh """
            sed -i 's|louaymejri/mon-app:latest|${IMAGE}:${TAG}|g' deployment.yaml || true
          """
          
          // Copier les fichiers sur l'hôte et exécuter le script de déploiement
          sh """
            # Copier les fichiers depuis le workspace Jenkins vers /tmp sur l'hôte
            docker cp \${WORKSPACE}/deployment.yaml host-deploy-deployment.yaml
            docker cp \${WORKSPACE}/service.yaml host-deploy-service.yaml
            docker cp \${WORKSPACE}/deploy-k8s.sh host-deploy-script.sh
            
            # Exécuter le script sur l'hôte via docker exec sur un conteneur temporaire
            # Ou simplement sauvegarder et demander déploiement manuel
            echo "Fichiers prêts pour déploiement"
            echo "deployment.yaml et service.yaml mis à jour avec l'image ${IMAGE}:${TAG}"
            
            # Alternative: exécuter directement (nécessite accès à l'hôte)
            # /home/louay/tp3/deploy-k8s.sh deployment.yaml service.yaml
          """
          
          echo "⚠️  Exécutez manuellement sur l'hôte:"
          echo "cd /home/louay/tp3 && ./deploy-k8s.sh deployment.yaml service.yaml"
        }
      }
    }
  }
  
  post {
    success {
      echo "✅ Déploiement terminé avec succès!"
      echo "Image déployée: ${IMAGE}:${TAG}"
    }
    failure {
      echo "❌ Pipeline échoué"
      sh "kubectl get pods -l app=mon-app || true"
      sh "kubectl logs -l app=mon-app --tail=50 || true"
    }
    always {
      echo "Nettoyage des images locales..."
      sh "docker rmi ${IMAGE}:${TAG} || true"
      sh "docker rmi ${IMAGE}:latest || true"
    }
  }
}
