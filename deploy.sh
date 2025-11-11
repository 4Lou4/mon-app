#!/bin/bash
# Kubernetes deployment script - runs on host with access to Minikube

set -e

DEPLOYMENT_FILE="$1"
SERVICE_FILE="$2"

export KUBECONFIG=/home/louay/.kube/config

echo "Applying deployment..."
kubectl apply -f "$DEPLOYMENT_FILE"

echo "Applying service..."
kubectl apply -f "$SERVICE_FILE"

echo "Waiting for rollout..."
kubectl rollout status deployment/mon-app-deployment --timeout=120s

echo "Deployment complete!"
kubectl get pods -l app=mon-app
kubectl get svc mon-app-service
