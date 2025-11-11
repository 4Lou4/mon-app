# TP3 - CI/CD Pipeline with Jenkins and Kubernetes

Node.js application with automated deployment using Jenkins and Kubernetes.

## Project Structure

```
tp3/
├── Dockerfile              # Docker image configuration
├── index.js                # Node.js application
├── package.json            # Node.js dependencies
├── deployment.yaml         # Kubernetes deployment
├── service.yaml            # Kubernetes service
├── Jenkinsfile             # CI/CD pipeline (kubectl)
├── Jenkinsfile-helm        # CI/CD pipeline (Helm)
└── mon-app-chart/          # Helm chart
```

## Prerequisites

- Docker Hub account
- Jenkins with Docker and Kubernetes plugins
- Kubernetes cluster (Minikube or similar)
- kubectl configured

## Jenkins Configuration

### Credentials

Create Docker Hub credentials in Jenkins:
- **ID**: `dockerhub-creds`
- **Type**: Username with password
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub token

### Pipeline Setup

1. Create new Pipeline job
2. Configure SCM: Git repository URL
3. Set Script Path: `Jenkinsfile` or `Jenkinsfile-helm`

## Deployment Methods

### Method 1: kubectl (Jenkinsfile)

Traditional deployment using kubectl commands:
- 6 stages
- Manual deployment file updates
- Direct kubectl apply

### Method 2: Helm (Jenkinsfile-helm)

Modern deployment using Helm charts:
- 4 stages
- Templated configuration
- Single helm upgrade command

## Verification

```bash
kubectl get pods
kubectl get svc mon-app-service
```

Access application: `http://<cluster-ip>:30080`

## Architecture

- Replicas: 2
- Service Type: NodePort (30080)
- Health Checks: Liveness and Readiness probes
- Resource Limits: CPU 100m, Memory 128Mi
# Test trigger - Tue 11 Nov 2025 06:17:18 PM CET
