import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

if (!GEMINI_API_KEY) {
  console.warn("WARNING: GEMINI_API_KEY is not set in environment variables.");
}

app.post('/api/insight', async (req, res) => {
  const { totalScore, meanScore, medianScore, level, responses } = req.body;

  if (!GEMINI_API_KEY) {
    return res.status(500).json({ error: "Gemini API key is not configured on the proxy server." });
  }

  // Build the details text from responses (matching Dart logic)
  let detailsText = "Détails des ressentis notés (de -2 à +2) par période de la journée :\n";

  if (Array.isArray(responses)) {
    for (const r of responses) {
      const periodDetails = [];

      const addPeriod = (name, values, comment) => {
        if (values && values.trim().length > 0) {
          const ratings = values.split(',').map(e => parseInt(e.trim(), 10)).filter(e => !isNaN(e));
          const formatted = ratings.map(r => r > 0 ? `+${r}` : `${r}`).join(', ');
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
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
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
      throw new Error(`Gemini API error: ${response.status} - ${errorText}`);
    }

    const data = await response.json();
    const insightText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!insightText) {
      throw new Error("Empty response from Gemini API");
    }

    res.json({ insight: insightText.trim() });
  } catch (error) {
    console.error("Proxy error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Gemini Proxy Server running on port ${PORT}`);
});
