FROM node:18-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package*.json
COPY package*.json ./

# Installer les dépendances de production uniquement
RUN npm ci --only=production

# Copier le reste des fichiers de l'application
COPY . .

# Exposer le port 80
EXPOSE 80

# Démarrer l'application
CMD ["node", "index.js"]
