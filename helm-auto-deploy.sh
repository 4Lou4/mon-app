#!/bin/bash

# Script de déploiement Helm automatique appelé par Jenkins
# Ce script tourne sur l'hôte et a accès à kubectl et helm

set -e  # Arrêter en cas d'erreur

IMAGE_TAG=$1
CHART_DIR="/home/louay/tp3/mon-app-chart"
RELEASE_NAME="mon-app"
NAMESPACE="default"
IMAGE_REPO="louaymejri/mon-app"

if [ -z "$IMAGE_TAG" ]; then
  echo "❌ Erreur: Tag d'image requis"
  echo "Usage: $0 <image-tag>"
  exit 1
fi

echo "⎈ Déploiement Helm automatique"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Release:   ${RELEASE_NAME}"
echo "🐳 Image:     ${IMAGE_REPO}:${IMAGE_TAG}"
echo "📂 Chart:     ${CHART_DIR}"
echo "🏷️  Namespace: ${NAMESPACE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Pull du dernier code
cd /home/louay/tp3
echo ""
echo "🔄 Pull du code depuis Git..."
git pull origin main || echo "⚠️  Déjà à jour"

# Vérifier que le chart existe
if [ ! -d "$CHART_DIR" ]; then
  echo "❌ Erreur: Chart Helm non trouvé dans $CHART_DIR"
  exit 1
fi

# Déployer avec Helm
echo ""
echo "⎈ Déploiement avec Helm upgrade --install..."
helm upgrade --install ${RELEASE_NAME} ${CHART_DIR} \
  --set image.repository=${IMAGE_REPO} \
  --set image.tag=${IMAGE_TAG} \
  --namespace ${NAMESPACE} \
  --wait \
  --timeout 120s

echo ""
echo "✅ Déploiement Helm réussi!"
echo ""
echo "📊 État de la release:"
helm status ${RELEASE_NAME} -n ${NAMESPACE}

echo ""
echo "📊 Pods déployés:"
kubectl get pods -l app.kubernetes.io/name=mon-app-chart -n ${NAMESPACE}

echo ""
echo "🌐 Services:"
kubectl get svc -l app.kubernetes.io/name=mon-app-chart -n ${NAMESPACE}

echo ""
echo "🔍 Image déployée:"
kubectl get deployment -l app.kubernetes.io/name=mon-app-chart -n ${NAMESPACE} -o jsonpath='{.items[0].spec.template.spec.containers[0].image}'
echo ""

echo ""
echo "🌐 Application accessible sur: http://192.168.49.2:30080"
echo ""

exit 0
