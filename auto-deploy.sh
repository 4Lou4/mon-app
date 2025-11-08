#!/bin/bash

# Script de déploiement automatique appelé par Jenkins
# Ce script tourne sur l'hôte et a accès à kubectl

set -e  # Arrêter en cas d'erreur

IMAGE_TAG=$1

if [ -z "$IMAGE_TAG" ]; then
  echo "❌ Erreur: Tag d'image requis"
  echo "Usage: $0 <image-tag>"
  exit 1
fi

echo "🚀 Déploiement automatique de louaymejri/mon-app:${IMAGE_TAG}"

# Mise à jour du fichier deployment.yaml
cd /home/louay/tp3
git pull origin main

echo "📝 Mise à jour de deployment.yaml avec l'image tag ${IMAGE_TAG}"
sed -i "s|image: louaymejri/mon-app:.*|image: louaymejri/mon-app:${IMAGE_TAG}|g" deployment.yaml

echo "📦 Application du déploiement sur Kubernetes..."
kubectl apply -f deployment.yaml

echo "⏳ Attente du rollout..."
kubectl rollout status deployment/mon-app-deployment --timeout=2m

echo "✅ Déploiement réussi!"
echo ""
echo "📊 État des pods:"
kubectl get pods -l app=mon-app

echo ""
echo "🔍 Image déployée:"
kubectl describe deployment mon-app-deployment | grep "Image:"

echo ""
echo "🌐 Application accessible sur: http://192.168.49.2:30080"

# Commit du changement
git add deployment.yaml
git commit -m "Auto-deploy: Update to image tag ${IMAGE_TAG}" || echo "Aucun changement à committer"
git push origin main

exit 0
