# 🚀 Système de Déploiement Automatique

## Vue d'ensemble

Ce système permet un déploiement **entièrement automatique** depuis Jenkins vers Kubernetes, contournant les limitations réseau entre le conteneur Jenkins et Minikube.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Jenkins Pipeline                          │
│  (dans conteneur Docker - réseau isolé)                     │
│                                                              │
│  1. Clone code                                              │
│  2. Build image Docker                                      │
│  3. Push vers Docker Hub                                    │
│  4. Écrit trigger → /tmp/jenkins-deploy-trigger            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Fichier trigger
                      ↓
┌─────────────────────────────────────────────────────────────┐
│              Deploy Watcher (sur l'hôte)                    │
│  Surveille /tmp/jenkins-deploy-trigger                      │
│                                                              │
│  Quand détecté:                                             │
│  → Exécute auto-deploy.sh                                  │
│  → Met à jour deployment.yaml                               │
│  → kubectl apply                                            │
│  → Commit changements                                       │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Fichiers

### `auto-deploy.sh`
Script principal de déploiement qui:
- Pull le dernier code depuis Git
- Met à jour `deployment.yaml` avec le nouveau tag
- Applique le déploiement sur Kubernetes
- Commit les changements

**Usage:**
```bash
./auto-deploy.sh <image-tag>
```

### `deploy-watcher.sh`
Service en arrière-plan qui:
- Surveille le fichier `/tmp/jenkins-deploy-trigger`
- Déclenche `auto-deploy.sh` quand un trigger est détecté
- Nettoie le trigger après exécution

**Usage:**
```bash
# Démarrer le watcher
nohup ./deploy-watcher.sh > /tmp/deploy-watcher.log 2>&1 &

# Voir les logs
tail -f /tmp/deploy-watcher.log

# Arrêter le watcher
pkill -f deploy-watcher.sh
```

### `Jenkinsfile` (modifié)
Stage "Deploy to Kubernetes" met à jour pour:
- Créer le fichier trigger avec le numéro de build
- Attendre que le watcher traite le trigger
- Vérifier que le déploiement est lancé

## 🚀 Installation

### 1. Démarrer le watcher (une seule fois)

```bash
cd /home/louay/tp3
nohup ./deploy-watcher.sh > /tmp/deploy-watcher.log 2>&1 &
```

### 2. Vérifier qu'il tourne

```bash
ps aux | grep deploy-watcher
tail -f /tmp/deploy-watcher.log
```

Vous devriez voir:
```
👀 En attente des déclencheurs de déploiement Jenkins...
Fichier trigger: /tmp/jenkins-deploy-trigger
```

## 🎯 Utilisation

### Workflow automatique

1. **Modifier le code** (ex: `index.js`)
2. **Commit et push** vers GitHub
3. **Lancer le build Jenkins** ("Build Now")
4. **Jenkins fait automatiquement:**
   - ✅ Clone
   - ✅ Build image
   - ✅ Push vers Docker Hub
   - ✅ **Déploiement Kubernetes** (nouveau!)
5. **Application mise à jour** automatiquement! 🎉

### Test manuel

```bash
# Tester le déploiement manuellement
./auto-deploy.sh 6

# Ou via le trigger (comme Jenkins)
echo "6" > /tmp/jenkins-deploy-trigger
```

## 📊 Monitoring

### Vérifier l'état du watcher

```bash
# Voir les logs en temps réel
tail -f /tmp/deploy-watcher.log

# Vérifier le processus
ps aux | grep deploy-watcher
```

### Vérifier le déploiement

```bash
# État des pods
kubectl get pods -l app=mon-app

# Image déployée
kubectl describe deployment mon-app-deployment | grep Image

# Tester l'application
curl http://192.168.49.2:30080
```

## 🔧 Dépannage

### Le watcher ne répond pas

```bash
# Arrêter l'ancien processus
pkill -f deploy-watcher.sh

# Redémarrer
nohup ./deploy-watcher.sh > /tmp/deploy-watcher.log 2>&1 &
```

### Le trigger n'est pas détecté

```bash
# Vérifier les permissions
ls -la /tmp/jenkins-deploy-trigger

# Vérifier que Jenkins peut écrire dans /tmp
docker exec jenkins touch /tmp/test && docker exec jenkins rm /tmp/test
```

### Le déploiement échoue

```bash
# Voir les logs détaillés
tail -50 /tmp/deploy-watcher.log

# Tester manuellement
./auto-deploy.sh 6
```

## ✅ Avantages

- ✅ **Déploiement 100% automatique** depuis Jenkins
- ✅ **Pas de configuration réseau complexe**
- ✅ **Logs centralisés** du déploiement
- ✅ **Facile à déboguer** (logs séparés)
- ✅ **Réutilisable** pour d'autres projets

## 🔄 Démarrage automatique au boot (optionnel)

Pour que le watcher démarre automatiquement au démarrage de la machine:

```bash
# Ajouter au crontab
(crontab -l 2>/dev/null; echo "@reboot nohup /home/louay/tp3/deploy-watcher.sh > /tmp/deploy-watcher.log 2>&1 &") | crontab -
```

## 📝 Notes

- Le watcher tourne en arrière-plan et consomme très peu de ressources
- Le fichier trigger est supprimé après chaque déploiement
- Les changements sont automatiquement committés sur GitHub
- Compatible avec n'importe quel nombre de builds Jenkins simultanés
