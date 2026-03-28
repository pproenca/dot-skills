import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline";

// ─── Config ────────────────────────────────────────────────────────────────

const LOG_DIR = "/var/log/myapp";

// Resolve and validate that a given filename stays within LOG_DIR.
// Throws if the resolved path escapes the allowed directory.
function resolveLogPath(filename: string): string {
  // Strip any leading slashes / path components — only bare filenames allowed
  const basename = path.basename(filename);
  const resolved = path.resolve(LOG_DIR, basename);
  if (!resolved.startsWith(path.resolve(LOG_DIR) + path.sep) &&
      resolved !== path.resolve(LOG_DIR)) {
    throw new Error(`Path traversal blocked: '${filename}' resolves outside ${LOG_DIR}`);
  }
  return resolved;
}

// Return all .log files in LOG_DIR
function listLogFiles(): string[] {
  try {
    return fs.readdirSync(LOG_DIR)
      .filter(f => f.endsWith(".log"))
      .map(f => path.join(LOG_DIR, f));
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    throw new Error(`Cannot list ${LOG_DIR}: ${msg}`);
  }
}

// Read the last `n` lines of a file efficiently
async function tailFile(filePath: string, n: number): Promise<string[]> {
  return new Promise((resolve, reject) => {
    const lines: string[] = [];
    const rl = readline.createInterface({
      input: fs.createReadStream(filePath),
      crlfDelay: Infinity,
    });
    rl.on("line", (line) => {
      lines.push(line);
      if (lines.length > n) lines.shift();
    });
    rl.on("close", () => resolve(lines));
    rl.on("error", reject);
  });
}

// Search a file for a pattern, returning up to maxResults matches
async function searchFile(
  filePath: string,
  regex: RegExp,
  maxResults: number,
): Promise<Array<{ file: string; line_number: number; line: string }>> {
  return new Promise((resolve, reject) => {
    const results: Array<{ file: string; line_number: number; line: string }> = [];
    let lineNum = 0;
    const rl = readline.createInterface({
      input: fs.createReadStream(filePath),
      crlfDelay: Infinity,
    });
    rl.on("line", (line) => {
      lineNum++;
      if (results.length >= maxResults) return;
      if (regex.test(line)) {
        results.push({ file: path.basename(filePath), line_number: lineNum, line });
      }
    });
    rl.on("close", () => resolve(results));
    rl.on("error", reject);
  });
}

// Known error severity patterns
const ERROR_PATTERNS: Array<{ label: string; regex: RegExp }> = [
  { label: "FATAL", regex: /\bFATAL\b/i },
  { label: "ERROR", regex: /\bERROR\b/i },
  { label: "WARN",  regex: /\bWARN(?:ING)?\b/i },
  { label: "EXCEPTION", regex: /Exception:|at\s+\w+\.\w+\(/ },
];

// ─── MCP Server ────────────────────────────────────────────────────────────

const server = new McpServer(
  { name: "myapp-logs", version: "0.1.0" },
  {
    instructions:
      "Use parse_errors for a quick health overview. " +
      "Use search_logs to find specific patterns. " +
      "Use tail_log to see the most recent activity in a file. " +
      "All tools are read-only and scoped to /var/log/myapp/.",
  },
);

// ── Tool 1: search_logs ────────────────────────────────────────────────────

server.registerTool(
  "search_logs",
  {
    description:
      "Search log files in /var/log/myapp/ for lines matching a pattern or regex. " +
      "Returns matching lines with filename and line number. " +
      "Does NOT follow symlinks and does NOT return real-time output — use tail_log for that.",
    inputSchema: {
      pattern: z.string().describe(
        "Regex or literal string to search for. Standard JS regex syntax."
      ),
      file: z.string().optional().describe(
        "Specific .log filename within /var/log/myapp/ (e.g. 'app.log'). " +
        "If omitted, all .log files are searched."
      ),
      max_results: z.number().int().min(1).max(500).default(50).describe(
        "Maximum number of matching lines to return across all searched files. Hard cap at 500."
      ),
      case_sensitive: z.boolean().default(false).describe(
        "Whether the pattern match is case-sensitive. Default false."
      ),
    },
    annotations: { readOnlyHint: true, idempotentHint: true },
  },
  async ({ pattern, file, max_results, case_sensitive }) => {
    let regex: RegExp;
    try {
      regex = new RegExp(pattern, case_sensitive ? "" : "i");
    } catch {
      return {
        isError: true,
        content: [{ type: "text", text: `Invalid regex: ${pattern}` }],
      };
    }

    const filePaths: string[] = [];
    if (file) {
      try {
        filePaths.push(resolveLogPath(file));
      } catch (err: unknown) {
        return {
          isError: true,
          content: [{ type: "text", text: err instanceof Error ? err.message : String(err) }],
        };
      }
    } else {
      try {
        filePaths.push(...listLogFiles());
      } catch (err: unknown) {
        return {
          isError: true,
          content: [{ type: "text", text: err instanceof Error ? err.message : String(err) }],
        };
      }
    }

    if (filePaths.length === 0) {
      return { content: [{ type: "text", text: "No .log files found in /var/log/myapp/" }] };
    }

    const allResults: Array<{ file: string; line_number: number; line: string }> = [];
    let remaining = max_results;

    for (const fp of filePaths) {
      if (remaining <= 0) break;
      try {
        const matches = await searchFile(fp, regex, remaining);
        allResults.push(...matches);
        remaining -= matches.length;
      } catch (err: unknown) {
        allResults.push({
          file: path.basename(fp),
          line_number: -1,
          line: `[Error reading file: ${err instanceof Error ? err.message : String(err)}]`,
        });
      }
    }

    const truncated = allResults.length >= max_results;
    const summary = truncated
      ? `Showing first ${allResults.length} matches (cap reached — refine the pattern to narrow down).`
      : `Found ${allResults.length} match(es).`;

    return {
      content: [{
        type: "text",
        text: summary + "\n\n" + JSON.stringify(allResults, null, 2),
      }],
    };
  },
);

// ── Tool 2: tail_log ───────────────────────────────────────────────────────

server.registerTool(
  "tail_log",
  {
    description:
      "Return the last N lines of a log file in /var/log/myapp/. " +
      "Use this to see the most recent activity. " +
      "Does NOT search — use search_logs for pattern matching.",
    inputSchema: {
      file: z.string().describe(
        "Filename within /var/log/myapp/ (e.g. 'app.log'). Required."
      ),
      lines: z.number().int().min(1).max(1000).default(100).describe(
        "Number of lines to return from the end of the file. Default 100, max 1000."
      ),
    },
    annotations: { readOnlyHint: true, idempotentHint: true },
  },
  async ({ file, lines }) => {
    let filePath: string;
    try {
      filePath = resolveLogPath(file);
    } catch (err: unknown) {
      return {
        isError: true,
        content: [{ type: "text", text: err instanceof Error ? err.message : String(err) }],
      };
    }

    if (!fs.existsSync(filePath)) {
      return {
        isError: true,
        content: [{ type: "text", text: `File not found: ${file}` }],
      };
    }

    let result: string[];
    try {
      result = await tailFile(filePath, lines);
    } catch (err: unknown) {
      return {
        isError: true,
        content: [{ type: "text", text: `Error reading ${file}: ${err instanceof Error ? err.message : String(err)}` }],
      };
    }

    const header = `=== ${file} — last ${result.length} line(s) ===\n`;
    return {
      content: [{ type: "text", text: header + result.join("\n") }],
    };
  },
);

// ── Tool 3: parse_errors ───────────────────────────────────────────────────

server.registerTool(
  "parse_errors",
  {
    description:
      "Scan log file(s) in /var/log/myapp/ for error patterns (FATAL, ERROR, WARN, exceptions). " +
      "Returns a structured summary grouped by severity with representative samples. " +
      "Use this for a quick health overview. " +
      "Use search_logs for precise pattern matching or to find specific messages.",
    inputSchema: {
      file: z.string().optional().describe(
        "Specific .log filename to scan (e.g. 'app.log'). If omitted, all .log files are scanned."
      ),
      max_per_severity: z.number().int().min(1).max(100).default(10).describe(
        "Maximum number of sample lines to collect per severity level. Default 10."
      ),
    },
    annotations: { readOnlyHint: true, idempotentHint: true },
  },
  async ({ file, max_per_severity }) => {
    const filePaths: string[] = [];
    if (file) {
      try {
        filePaths.push(resolveLogPath(file));
      } catch (err: unknown) {
        return {
          isError: true,
          content: [{ type: "text", text: err instanceof Error ? err.message : String(err) }],
        };
      }
    } else {
      try {
        filePaths.push(...listLogFiles());
      } catch (err: unknown) {
        return {
          isError: true,
          content: [{ type: "text", text: err instanceof Error ? err.message : String(err) }],
        };
      }
    }

    if (filePaths.length === 0) {
      return { content: [{ type: "text", text: "No .log files found in /var/log/myapp/" }] };
    }

    // Accumulate counts and samples per severity
    const severityCounts: Record<string, number> = {};
    const severitySamples: Record<string, string[]> = {};
    for (const { label } of ERROR_PATTERNS) {
      severityCounts[label] = 0;
      severitySamples[label] = [];
    }

    for (const fp of filePaths) {
      try {
        await new Promise<void>((resolve, reject) => {
          const rl = readline.createInterface({
            input: fs.createReadStream(fp),
            crlfDelay: Infinity,
          });
          rl.on("line", (line) => {
            for (const { label, regex } of ERROR_PATTERNS) {
              if (regex.test(line)) {
                severityCounts[label]++;
                if (severitySamples[label].length < max_per_severity) {
                  severitySamples[label].push(`[${path.basename(fp)}] ${line.trim()}`);
                }
                break; // count the line once under the highest-priority matching label
              }
            }
          });
          rl.on("close", resolve);
          rl.on("error", reject);
        });
      } catch (err: unknown) {
        // Record the error but continue scanning other files
        severitySamples["ERROR"] = severitySamples["ERROR"] ?? [];
        severitySamples["ERROR"].push(
          `[Error reading ${path.basename(fp)}: ${err instanceof Error ? err.message : String(err)}]`
        );
      }
    }

    const totalErrors =
      severityCounts["FATAL"] +
      severityCounts["ERROR"] +
      severityCounts["EXCEPTION"];
    const totalWarns = severityCounts["WARN"];

    const report = {
      summary: {
        files_scanned: filePaths.length,
        fatal_count: severityCounts["FATAL"],
        error_count: severityCounts["ERROR"],
        exception_count: severityCounts["EXCEPTION"],
        warn_count: totalWarns,
        total_issues: totalErrors + totalWarns,
      },
      samples: Object.fromEntries(
        ERROR_PATTERNS
          .filter(({ label }) => severityCounts[label] > 0)
          .map(({ label }) => [label, severitySamples[label]])
      ),
    };

    const headline =
      totalErrors > 0
        ? `Found ${totalErrors} error(s) and ${totalWarns} warning(s) across ${filePaths.length} file(s).`
        : totalWarns > 0
        ? `No errors found. ${totalWarns} warning(s) across ${filePaths.length} file(s).`
        : `No issues found across ${filePaths.length} file(s).`;

    return {
      content: [{
        type: "text",
        text: headline + "\n\n" + JSON.stringify(report, null, 2),
      }],
    };
  },
);

// ─── Start (stdio transport for local personal use) ─────────────────────────

const transport = new StdioServerTransport();
await server.connect(transport);
