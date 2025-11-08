#!/bin/bash

# Wrapper pour permettre à Jenkins de déclencher le déploiement
# Ce script écoute un fichier trigger créé par Jenkins

TRIGGER_FILE="/tmp/jenkins-deploy-trigger"
DEPLOY_SCRIPT="/home/louay/tp3/auto-deploy.sh"

# Créer le répertoire si nécessaire
mkdir -p /tmp

echo "👀 En attente des déclencheurs de déploiement Jenkins..."
echo "Fichier trigger: $TRIGGER_FILE"

while true; do
  if [ -f "$TRIGGER_FILE" ]; then
    IMAGE_TAG=$(cat "$TRIGGER_FILE")
    echo ""
    echo "🔔 Déclencheur détecté! Tag d'image: $IMAGE_TAG"
    
    # Exécuter le déploiement
    bash "$DEPLOY_SCRIPT" "$IMAGE_TAG"
    
    # Supprimer le fichier trigger
    rm -f "$TRIGGER_FILE"
    
    echo ""
    echo "✅ Déploiement terminé. En attente du prochain trigger..."
  fi
  
  sleep 2
done
