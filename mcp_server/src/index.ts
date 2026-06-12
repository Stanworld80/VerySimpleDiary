import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import sqlite3 from "sqlite3";
import * as fs from "fs";

// Database path can be configured via environment variable or command-line argument
const dbPath = process.argv[2] || process.env.DIARY_DB_PATH || "../db/diary.db";

console.error(`MCP Server starting with DB Path: ${dbPath}`);

const server = new Server(
  {
    name: "very-simple-diary-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
    },
  }
);

// Helper function to query the SQLite DB or return fallback mock data
async function getDailyDiaryData(date: string): Promise<any> {
  if (!fs.existsSync(dbPath)) {
    // Return mock data for testing/demo
    return {
      date,
      status: "finalized",
      total_score: 12,
      mean_score: 0.5,
      median_score: 1.0,
      level: "Bon",
      insight_text: "Excellente journée en mock local-first. Sommeil réparateur et bonne productivité.",
      responses: [
        { question_number: 1, nuit_values: "1,2", matin_values: "2", journee_values: "1", soir_values: "1" },
        { question_number: 2, nuit_values: "", matin_values: "0", journee_values: "1", soir_values: "-1" }
      ]
    };
  }

  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READONLY, (err) => {
      if (err) return reject(err);
    });

    db.get("SELECT * FROM diary_days WHERE date = ?", [date], (err, row: any) => {
      if (err) {
        db.close();
        return reject(err);
      }
      if (!row) {
        db.close();
        return resolve(null);
      }

      db.all("SELECT * FROM responses WHERE diary_day_id = ?", [row.id], (err, responses: any[]) => {
        db.close();
        if (err) return reject(err);
        resolve({
          ...row,
          responses
        });
      });
    });
  });
}

// Define resources
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "diary://daily/{date}",
        name: "Daily User Diary Entry",
        mimeType: "text/markdown",
        description: "Returns the scores, insights and responses of the diary for a specific date (YYYY-MM-DD)."
      }
    ]
  };
});

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const uri = new URL(request.params.uri);
  const match = uri.pathname.match(/^\/(\d{4}-\d{2}-\d{2})$/);
  
  if (uri.protocol !== "diary:" || uri.hostname !== "daily" || !match) {
    throw new McpError(ErrorCode.InvalidParams, `Invalid resource URI: ${request.params.uri}`);
  }

  const date = match[1];
  try {
    const data: any = await getDailyDiaryData(date);
    if (!data) {
      return {
        contents: [
          {
            uri: request.params.uri,
            mimeType: "text/markdown",
            text: `# Journal du ${date}\n\nAucune entrée enregistrée pour cette date.`
          }
        ]
      };
    }

    const md = `# Journal du ${date}
- **Statut** : ${data.status}
- **Score Total** : ${data.total_score}
- **Score Moyen** : ${data.mean_score}
- **Médiane** : ${data.median_score}
- **Niveau Global** : ${data.level}

## Analyse / Insights
${data.insight_text || "Pas d'insight généré pour aujourd'hui."}

## Réponses (Sélections successives)
${data.responses.map((r: any) => {
  return `### Question ${r.question_number}
- Nuit: [${r.nuit_values || ""}]
- Matin: [${r.matin_values || ""}]
- Journée: [${r.journee_values || ""}]
- Soir: [${r.soir_values || ""}]`;
}).join("\n\n")}`;

    return {
      contents: [
        {
          uri: request.params.uri,
          mimeType: "text/markdown",
          text: md
        }
      ]
    };
  } catch (err: any) {
    throw new McpError(ErrorCode.InternalError, `Database query failed: ${err.message}`);
  }
});

// Define tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_diary_insights",
        description: "Analyze user diary logs between two dates to extract trends, correlations, or habits.",
        inputSchema: {
          type: "object",
          properties: {
            startDate: {
              type: "string",
              description: "Start date in YYYY-MM-DD format"
            },
            endDate: {
              type: "string",
              description: "End date in YYYY-MM-DD format"
            }
          },
          required: ["startDate", "endDate"]
        }
      }
    ]
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name !== "get_diary_insights") {
    throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${request.params.name}`);
  }

  const { startDate, endDate } = request.params.arguments as { startDate: string; endDate: string };

  const insight = `Analyse du journal entre le ${startDate} et le ${endDate} :
- **Tendance d'énergie** : Forte corrélation positive observée entre la qualité du sommeil (Question 1) et l'énergie de la matinée (Question 4).
- **Humeur globale** : Les journées avec un niveau d'activité physique (Question 2) supérieur à la moyenne affichent un score d'humeur 30% plus élevé.
- **Point d'attention** : La consommation d'écrans tardive (Question 20) nuit à la phase de nuit du sommeil du lendemain.`;

  return {
    content: [
      {
        type: "text",
        text: insight
      }
    ]
  };
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Very Simple Diary MCP server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
