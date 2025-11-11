pipeline {
  agent any
  
  environment {
    IMAGE = "louaymejri/mon-app"
    TAG = "${env.BUILD_NUMBER}"
  }
  
  stages {
    stage('Clone') {
      steps {
        echo "Cloning Git repository..."
        git url: 'https://github.com/4Lou4/mon-app.git', branch: 'main'
      }
    }
    
    stage('Build Docker Image') {
      steps {
        echo "Building Docker image..."
        script {
          sh "docker build -t ${IMAGE}:${TAG} ."
          sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
        }
      }
    }
    
    stage('Push Image') {
      steps {
        echo "Pushing image to Docker Hub..."
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
    
    stage('Update Deployment File') {
      steps {
        echo "Updating deployment.yaml with new image tag..."
        script {
          sh """
            sed -i 's|image: louaymejri/mon-app:.*|image: ${IMAGE}:${TAG}|g' deployment.yaml
            echo "Updated image in deployment.yaml:"
            grep "image:" deployment.yaml
          """
        }
      }
    }
    
    stage('Deploy to Kubernetes') {
      steps {
        echo "Deploying to Kubernetes cluster..."
        script {
          sh """
            # Set kubeconfig path
            export KUBECONFIG=/root/.kube/config
            
            # Apply deployment and service
            kubectl apply -f deployment.yaml
            kubectl apply -f service.yaml
            
            # Wait for rollout to complete
            kubectl rollout status deployment/mon-app-deployment --timeout=120s
          """
        }
      }
    }
    
    stage('Verify Deployment') {
      steps {
        echo "Verifying deployment..."
        script {
          sh """
            export KUBECONFIG=/root/.kube/config
            kubectl get pods -l app=mon-app
            kubectl get svc mon-app-service
          """
        }
      }
    }
  }
  
  post {
    success {
      echo "Pipeline completed successfully!"
      echo "Deployed image: ${IMAGE}:${TAG}"
      echo "Application URL: http://192.168.58.2:30080"
    }
    failure {
      echo "Pipeline failed"
      sh """
        export KUBECONFIG=/root/.kube/config
        kubectl get pods -l app=mon-app || true
        kubectl logs -l app=mon-app --tail=50 || true
      """
    }
    always {
      echo "Cleaning up local images..."
      sh "docker rmi ${IMAGE}:${TAG} || true"
    }
  }
}
