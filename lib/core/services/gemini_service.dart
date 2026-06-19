import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../db/local_database.dart';
import '../../features/diary/controller/diary_controller.dart'; // to reference diaryQuestionsList

class GeminiService {
  static Future<String> generateInsight({
    required String apiKey,
    required String mode,
    required String proxyUrl,
    required double totalScore,
    required double meanScore,
    required double medianScore,
    required String level,
    required List<DiaryResponse> responses,
  }) async {
    if (mode == 'proxy') {
      return _generateInsightViaProxy(
        proxyUrl: proxyUrl,
        totalScore: totalScore,
        meanScore: meanScore,
        medianScore: medianScore,
        level: level,
        responses: responses,
      );
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    // Build details of the day's answers
    final StringBuffer detailsBuffer = StringBuffer();
    detailsBuffer.writeln("Détails des ressentis notés (de -2 à +2) par période de la journée :");

    for (final response in responses) {
      final question = diaryQuestionsList.firstWhere(
        (q) => q.number == response.questionNumber,
        orElse: () => DiaryQuestion(
          number: response.questionNumber,
          category: 'Autre',
          title: 'Question ${response.questionNumber}',
          description: '',
        ),
      );

      final List<String> periodDetails = [];
      
      void addPeriod(String name, String values, String comment) {
        if (values.trim().isNotEmpty) {
          final ratings = values.split(',').map((e) => int.tryParse(e) ?? 0).toList();
          final formatted = ratings.map((r) => r > 0 ? '+$r' : '$r').join(', ');
          var detail = "$name: $formatted";
          if (comment.trim().isNotEmpty) {
            detail += " (note: \"$comment\")";
          }
          periodDetails.add(detail);
        } else if (comment.trim().isNotEmpty) {
          periodDetails.add("$name: (note: \"$comment\")");
        }
      }

      addPeriod('Nuit', response.nuitValues, response.nuitComment);
      addPeriod('Matin', response.matinValues, response.matinComment);
      addPeriod('Journée', response.journeeValues, response.journeeComment);
      addPeriod('Soir', response.soirValues, response.soirComment);

      if (periodDetails.isNotEmpty) {
        detailsBuffer.writeln("- Q${question.number} [${question.title}] (${question.description}) :");
        for (final detail in periodDetails) {
          detailsBuffer.writeln("    * $detail");
        }
      }
    }

    final prompt = """
Tu es un coach personnel de bien-être bienveillant, constructif et encourageant.
Voici le récapitulatif des ressentis saisis par l'utilisateur pour aujourd'hui dans son journal de bord :

- Niveau global estimé : $level
- Score total cumulé : ${totalScore.toStringAsFixed(0)}
- Score moyen : ${meanScore.toStringAsFixed(2)}
- Score médian : ${medianScore.toStringAsFixed(1)}

${detailsBuffer.toString()}

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
""";

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception("Réponse vide de Gemini");
    }
    return text.trim();
  }

  static Future<String> _generateInsightViaProxy({
    required String proxyUrl,
    required double totalScore,
    required double meanScore,
    required double medianScore,
    required String level,
    required List<DiaryResponse> responses,
  }) async {
    if (proxyUrl.trim().isEmpty) {
      throw Exception("L'URL du proxy est vide.");
    }

    final client = HttpClient();
    try {
      final uri = Uri.parse(proxyUrl);
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final body = {
        'totalScore': totalScore,
        'meanScore': meanScore,
        'medianScore': medianScore,
        'level': level,
        'responses': responses.map((r) => {
          'questionNumber': r.questionNumber,
          'nuitValues': r.nuitValues,
          'nuitComment': r.nuitComment,
          'matinValues': r.matinValues,
          'matinComment': r.matinComment,
          'journeeValues': r.journeeValues,
          'journeeComment': r.journeeComment,
          'soirValues': r.soirValues,
          'soirComment': r.soirComment,
        }).toList(),
      };

      request.write(jsonEncode(body));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception("Erreur du serveur proxy (code : ${response.statusCode})");
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      
      if (data is Map && data.containsKey('insight')) {
        return data['insight'] as String;
      } else {
        throw Exception("Réponse du proxy invalide (clé 'insight' manquante).");
      }
    } finally {
      client.close();
    }
  }
}
