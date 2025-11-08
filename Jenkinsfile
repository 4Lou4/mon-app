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
        git url: 'https://github.com/<ton-utilisateur>/mon-app.git', branch: 'main'
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
          
          // Appliquer les manifestes Kubernetes
          sh "kubectl apply -f deployment.yaml"
          sh "kubectl apply -f service.yaml"
          
          // Attendre que le déploiement soit terminé
          sh "kubectl rollout status deployment/mon-app-deployment --timeout=120s"
          
          // Afficher le statut
          sh "kubectl get pods -l app=mon-app"
          sh "kubectl get svc mon-app-service"
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
