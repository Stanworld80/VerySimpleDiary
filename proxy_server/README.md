# Serveur Proxy Gemini - Very Simple Diary

Ce dossier contient un serveur proxy ultra-léger en Node.js pour servir d'intermédiaire de confiance entre votre application **Very Simple Diary** et l'API de Google Gemini.

Il permet de masquer et de sécuriser votre clé API Gemini personnelle (issue de Google AI Studio) sans l'exposer dans l'application mobile ou de bureau distribuée à vos utilisateurs.

## Configuration & Lancement local

### 1. Installation des dépendances
Installez Node.js sur votre machine, puis exécutez dans ce dossier :
```bash
npm install
```

### 2. Variables d'environnement
Copiez le fichier `.env.example` en le renommant `.env` :
```bash
cp .env.example .env
```
Éditez le fichier `.env` et remplacez `votre_cle_api_gemini_ici` par votre clé API réelle obtenue sur [Google AI Studio](https://aistudio.google.com/).

### 3. Lancement
Démarrez le serveur localement :
```bash
npm start
```
Le serveur écoutera par défaut sur le port `3000`. L'URL d'intégration locale à saisir dans l'application sera :
`http://localhost:3000/api/insight` (ou `http://10.0.2.2:3000/api/insight` sur un émulateur Android).

---

## Déploiement en Production

Vous pouvez déployer ce proxy très facilement et gratuitement sur des plateformes Cloud comme :
- **Render**
- **Vercel**
- **Railway**
- **Google Cloud Functions / Cloud Run**

### Exemple de déploiement en 2 minutes sur Render :
1. Créez un compte gratuit sur [Render](https://render.com/).
2. Connectez votre dépôt GitHub.
3. Créez un nouveau **Web Service**.
4. Spécifiez :
   - **Environment** : `Node`
   - **Build Command** : `npm install`
   - **Start Command** : `npm start`
5. Ajoutez une variable d'environnement (Environment Variable) :
   - `GEMINI_API_KEY` : *Votre clé API Google Gemini réelle*.
6. Render va vous attribuer une URL publique HTTPS (ex: `https://mon-proxy-diary.onrender.com`).
7. L'URL complète à renseigner dans l'application Very Simple Diary sera :
   `https://mon-proxy-diary.onrender.com/api/insight`
