#!/bin/bash

# Watcher pour déploiement Helm automatique
# Surveille le fichier trigger créé par Jenkins pour Helm

TRIGGER_FILE="/tmp/jenkins-helm-deploy-trigger"
DEPLOY_SCRIPT="/home/louay/tp3/helm-auto-deploy.sh"

# Créer le répertoire si nécessaire
mkdir -p /tmp

echo "⎈ Watcher Helm démarré"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👀 En attente des déclencheurs Helm de Jenkins..."
echo "📁 Fichier trigger: $TRIGGER_FILE"
echo "🔧 Script deploy:   $DEPLOY_SCRIPT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

while true; do
  if [ -f "$TRIGGER_FILE" ]; then
    TRIGGER_CONTENT=$(cat "$TRIGGER_FILE")
    
    # Vérifier si c'est un trigger Helm (format: helm:TAG)
    if [[ "$TRIGGER_CONTENT" == helm:* ]]; then
      IMAGE_TAG="${TRIGGER_CONTENT#helm:}"
      
      echo ""
      echo "🔔 Déclencheur Helm détecté!"
      echo "🏷️  Tag d'image: $IMAGE_TAG"
      echo ""
      
      # Exécuter le déploiement Helm
      bash "$DEPLOY_SCRIPT" "$IMAGE_TAG"
      
      # Supprimer le fichier trigger
      rm -f "$TRIGGER_FILE"
      
      echo ""
      echo "✅ Déploiement Helm terminé."
      echo "👀 En attente du prochain trigger..."
      echo ""
    else
      echo "⚠️  Format de trigger invalide, ignoré: $TRIGGER_CONTENT"
      rm -f "$TRIGGER_FILE"
    fi
  fi
  
  sleep 2
done
