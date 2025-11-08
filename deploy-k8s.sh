#!/bin/bash
# Script de déploiement Kubernetes appelé depuis Jenkins
# Ce script s'exécute sur l'HÔTE, pas dans le conteneur Jenkins

set -e

DEPLOYMENT_FILE=${1:-deployment.yaml}
SERVICE_FILE=${2:-service.yaml}

echo "🚀 Déploiement sur Kubernetes..."
echo "Fichier deployment: $DEPLOYMENT_FILE"
echo "Fichier service: $SERVICE_FILE"

# Appliquer le déploiement
echo "📦 Application du déploiement..."
kubectl apply -f "$DEPLOYMENT_FILE"

# Appliquer le service
echo "🌐 Application du service..."
kubectl apply -f "$SERVICE_FILE"

# Attendre que le déploiement soit prêt
echo "⏳ Attente du rollout..."
kubectl rollout status deployment/mon-app-deployment --timeout=120s

# Afficher l'état
echo "✅ Déploiement terminé!"
echo ""
echo "Pods:"
kubectl get pods -l app=mon-app

echo ""
echo "Service:"
kubectl get svc mon-app-service

echo ""
echo "🎉 Application accessible sur: http://$(minikube ip):30080"
