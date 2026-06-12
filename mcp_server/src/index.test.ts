import { test, describe } from "node:test";
import assert from "node:assert";
import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const serverPath = path.join(__dirname, "index.js");

describe("MCP Server Integration Tests", () => {
  // Helper to run JSON-RPC requests against the spawned server
  function runRequest(requestObj: any): Promise<any> {
    return new Promise((resolve, reject) => {
      const child = spawn("node", [serverPath, "mock-non-existent-db.db"], {
        env: { ...process.env, DIARY_DB_PATH: "mock-non-existent-db.db" },
      });

      let stdoutData = "";
      let stderrData = "";

      child.stdout.on("data", (data) => {
        stdoutData += data.toString();
        // Since standard JSON-RPC over stdio prints line-by-line or complete messages,
        // we can try to parse the buffer as it comes.
        try {
          const response = JSON.parse(stdoutData.trim());
          child.kill();
          resolve(response);
        } catch (e) {
          // Keep accumulating
        }
      });

      child.stderr.on("data", (data) => {
        stderrData += data.toString();
      });

      child.on("error", (err) => {
        reject(err);
      });

      child.on("exit", (code) => {
        try {
          if (stdoutData.trim()) {
            const response = JSON.parse(stdoutData.trim());
            resolve(response);
          } else {
            reject(new Error(`Server exited with code ${code}. Stderr: ${stderrData}`));
          }
        } catch (e) {
          reject(new Error(`Failed to parse response: ${stdoutData}. Stderr: ${stderrData}`));
        }
      });

      // Write the request to stdin
      child.stdin.write(JSON.stringify(requestObj) + "\n");
    });
  }

  test("List Resources should return diary://daily/{date}", async () => {
    const response = await runRequest({
      jsonrpc: "2.0",
      id: 1,
      method: "resources/list",
    });

    assert.ok(response);
    assert.strictEqual(response.jsonrpc, "2.0");
    assert.strictEqual(response.id, 1);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.resources));
    
    const resource = response.result.resources.find(
      (r: any) => r.uri === "diary://daily/{date}"
    );
    assert.ok(resource, "Resource diary://daily/{date} not found");
    assert.strictEqual(resource.name, "Daily User Diary Entry");
    assert.strictEqual(resource.mimeType, "text/markdown");
  });

  test("Read Resource should return markdown for a valid date", async () => {
    const response = await runRequest({
      jsonrpc: "2.0",
      id: 2,
      method: "resources/read",
      params: {
        uri: "diary://daily/2026-06-12",
      },
    });

    assert.ok(response);
    assert.strictEqual(response.jsonrpc, "2.0");
    assert.strictEqual(response.id, 2);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.contents));
    assert.strictEqual(response.result.contents[0].uri, "diary://daily/2026-06-12");
    assert.strictEqual(response.result.contents[0].mimeType, "text/markdown");
    assert.ok(response.result.contents[0].text.includes("# Journal du 2026-06-12"));
    assert.ok(response.result.contents[0].text.includes("Niveau Global"));
  });

  test("List Tools should return get_diary_insights", async () => {
    const response = await runRequest({
      jsonrpc: "2.0",
      id: 3,
      method: "tools/list",
    });

    assert.ok(response);
    assert.strictEqual(response.jsonrpc, "2.0");
    assert.strictEqual(response.id, 3);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.tools));

    const tool = response.result.tools.find(
      (t: any) => t.name === "get_diary_insights"
    );
    assert.ok(tool, "Tool get_diary_insights not found");
    assert.ok(tool.inputSchema.properties.startDate);
    assert.ok(tool.inputSchema.properties.endDate);
  });

  test("Call Tool should return correct insights", async () => {
    const response = await runRequest({
      jsonrpc: "2.0",
      id: 4,
      method: "tools/call",
      params: {
        name: "get_diary_insights",
        arguments: {
          startDate: "2026-06-01",
          endDate: "2026-06-07",
        },
      },
    });

    assert.ok(response);
    assert.strictEqual(response.jsonrpc, "2.0");
    assert.strictEqual(response.id, 4);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.content));
    assert.strictEqual(response.result.content[0].type, "text");
    assert.ok(response.result.content[0].text.includes("Analyse du journal entre le 2026-06-01 et le 2026-06-07"));
    assert.ok(response.result.content[0].text.includes("Tendance d'énergie"));
  });
});
