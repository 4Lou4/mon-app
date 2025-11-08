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
          // Déclencher le déploiement automatique via le fichier trigger
          sh """
            echo "🚀 Déclenchement du déploiement automatique..."
            echo "${TAG}" > /tmp/jenkins-deploy-trigger
            echo "✅ Trigger créé avec le tag: ${TAG}"
            
            # Attendre un peu que le watcher détecte le trigger
            echo "⏳ Attente du déploiement (max 30s)..."
            for i in {1..15}; do
              if [ ! -f /tmp/jenkins-deploy-trigger ]; then
                echo "✅ Déploiement déclenché avec succès!"
                exit 0
              fi
              sleep 2
            done
            
            echo "⚠️  Le déploiement est en cours ou le watcher n'est pas actif"
            echo "Si le watcher n'est pas démarré, exécutez:"
            echo "  /home/louay/tp3/deploy-watcher.sh &"
          """
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
