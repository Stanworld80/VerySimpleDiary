const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Ce proxy utilise Firebase Secret Manager pour stocker la clé API Gemini en toute sécurité.
// Pour configurer la clé sur Firebase :
// firebase functions:secrets:set GEMINI_API_KEY=VOTRE_CLE_API_GEMINI
exports.getGeminiInsight = onRequest({ secrets: ["GEMINI_API_KEY"], cors: true }, async (req, res) => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    res.status(500).json({ error: "La clé API Gemini (GEMINI_API_KEY) n'est pas configurée dans les secrets de Firebase." });
    return;
  }

  const { totalScore, meanScore, medianScore, level, responses } = req.body;

  // Construction du détail des ressentis identique à l'application Flutter
  let detailsText = "Détails des ressentis notés (de -2 à +2) par période de la journée :\n";

  if (Array.isArray(responses)) {
    for (const r of responses) {
      const periodDetails = [];

      const addPeriod = (name, values, comment) => {
        if (values && values.trim().length > 0) {
          const ratings = values.split(',').map(e => parseInt(e.trim(), 10)).filter(e => !isNaN(e));
          const formatted = ratings.map(val => val > 0 ? `+${val}` : `${val}`).join(', ');
          let detail = `${name}: ${formatted}`;
          if (comment && comment.trim().length > 0) {
            detail += ` (note: "${comment}")`;
          }
          periodDetails.push(detail);
        } else if (comment && comment.trim().length > 0) {
          periodDetails.push(`${name}: (note: "${comment}")`);
        }
      };

      addPeriod('Nuit', r.nuitValues, r.nuitComment);
      addPeriod('Matin', r.matinValues, r.matinComment);
      addPeriod('Journée', r.journeeValues, r.journeeComment);
      addPeriod('Soir', r.soirValues, r.soirComment);

      if (periodDetails.length > 0) {
        detailsText += `- Question ${r.questionNumber} :\n`;
        for (const detail of periodDetails) {
          detailsText += `    * ${detail}\n`;
        }
      }
    }
  }

  const prompt = `
Tu es un coach personnel de bien-être bienveillant, constructif et encourageant.
Voici le récapitulatif des ressentis saisis par l'utilisateur pour aujourd'hui dans son journal de bord :

- Niveau global estimé : ${level}
- Score total cumulé : ${totalScore}
- Score moyen : ${meanScore?.toFixed(2)}
- Score médian : ${medianScore?.toFixed(1)}

${detailsText}

En te basant sur ces données :
1. Rédige une phrase chaleureuse pour résumer l'état général ou l'humeur de sa journée.
2. Identifie 1 ou 2 points forts (les aspects positifs qui se sont bien passés aujourd'hui) et formule des encouragements ou félicitations.
3. Repère 1 ou 2 points faibles ou axes d'amélioration clés (ex: douleurs, fatigue, manque de sport, stress, mauvaise alimentation) et formule 1 ou 2 conseils concrets et positifs pour l'aider à focaliser son attention et à s'améliorer.

Directives importantes :
- Rédige en français.
- Sois très bienveillant, positif et direct (parle directement à l'utilisateur : vouvoie-le).
- Reste concis (environ 3 à 5 phrases, 120-150 mots maximum).
- Ne mets pas de titres de sections comme "Points forts" ou "Points faibles". Écris un texte fluide, structuré en 2 paragraphes simples.
- Ne parle pas de scores numériques, de médianes ou d'aspects techniques de l'application dans le texte final. Concentre-toi uniquement sur le bien-être physique et psychologique.
- Si le récapitulatif ne contient aucune donnée, invite simplement l'utilisateur avec bienveillance à compléter ses ressentis.
`;

  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: prompt
          }]
        }]
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Erreur API Gemini: ${response.status} - ${errorText}`);
    }

    const data = await response.json();
    const insightText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!insightText) {
      throw new Error("Réponse vide de l'API Gemini");
    }

    res.json({ insight: insightText.trim() });
  } catch (error) {
    logger.error("Erreur de proxy:", error);
    res.status(500).json({ error: error.message });
  }
});
