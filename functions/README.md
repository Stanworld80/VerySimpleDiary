# Proxy Gemini - Firebase Cloud Functions

Ce dossier contient l'implémentation du proxy Gemini sous forme de **Firebase Cloud Functions (v2)**. Cela vous permet d'héberger le proxy directement au sein de votre infrastructure Firebase existante.

## Configuration & Déploiement

### 1. Enregistrer votre clé API dans Firebase Secret Manager
Pour que la fonction Cloud accède à votre clé API Gemini de manière sécurisée (sans la mettre en clair dans le code), nous utilisons le Secret Manager de Firebase.

Dans votre terminal à la racine du projet, exécutez :
```bash
firebase functions:secrets:set GEMINI_API_KEY
```
Saisissez ensuite votre clé API Gemini réelle issue de [Google AI Studio](https://aistudio.google.com/).

### 2. Déployer la fonction
Déployez uniquement la fonction Cloud avec la commande suivante :
```bash
firebase deploy --only functions
```

### 3. Configurer l'application Very Simple Diary
Une fois le déploiement terminé, Firebase vous donnera une URL publique sécurisée pour votre fonction. Elle ressemblera à ceci :
`https://getgeminiinsight-<ID_DE_VOTRE_PROJET_FIREBASE>.run.app`

Il vous suffit de :
1. Ouvrir les **Paramètres** de l'application (bouton Profil).
2. Choisir le mode **Serveur Proxy (Option B)**.
3. Renseigner l'URL fournie par Firebase.
