import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as fs from "fs";
import * as path from "path";
import { z } from "zod";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const LOG_BASE_DIR = "/var/log/myapp";

// ---------------------------------------------------------------------------
// Path safety helper
// ---------------------------------------------------------------------------

/**
 * Resolves a filename relative to LOG_BASE_DIR and verifies the resolved path
 * stays inside LOG_BASE_DIR (prevents directory traversal).
 * Throws an Error if the path escapes the base directory.
 */
function safeLogPath(filename: string): string {
  const resolved = path.resolve(LOG_BASE_DIR, filename);
  if (!resolved.startsWith(path.resolve(LOG_BASE_DIR) + path.sep) &&
      resolved !== path.resolve(LOG_BASE_DIR)) {
    throw new Error(`Access denied: '${filename}' resolves outside ${LOG_BASE_DIR}`);
  }
  return resolved;
}

// ---------------------------------------------------------------------------
// File helpers
// ---------------------------------------------------------------------------

/** Read all .log files in LOG_BASE_DIR (non-recursive). */
function listLogFiles(): string[] {
  try {
    return fs
      .readdirSync(LOG_BASE_DIR)
      .filter((f) => f.endsWith(".log"))
      .map((f) => path.join(LOG_BASE_DIR, f));
  } catch (err) {
    throw new Error(`Cannot list ${LOG_BASE_DIR}: ${(err as Error).message}`);
  }
}

/** Read a file and return its lines. */
function readLines(filePath: string): string[] {
  const content = fs.readFileSync(filePath, "utf8");
  return content.split("\n");
}

// ---------------------------------------------------------------------------
// Tool: search_logs
// ---------------------------------------------------------------------------

const SearchLogsSchema = z.object({
  pattern: z.string().describe("Regex or literal string to search for"),
  filename: z
    .string()
    .optional()
    .describe("Specific file under /var/log/myapp/. Omit to search all .log files."),
  case_sensitive: z
    .boolean()
    .optional()
    .default(false)
    .describe("Whether the search is case-sensitive. Default false."),
  max_results: z
    .number()
    .int()
    .positive()
    .optional()
    .default(200)
    .describe("Maximum number of matching lines to return. Default 200."),
});

type SearchLogsInput = z.infer<typeof SearchLogsSchema>;

interface SearchMatch {
  file: string;
  line_number: number;
  content: string;
}

function searchLogs(input: SearchLogsInput): SearchMatch[] {
  const flags = input.case_sensitive ? "" : "i";
  let regex: RegExp;
  try {
    regex = new RegExp(input.pattern, flags);
  } catch {
    // Fall back to literal match if pattern is not valid regex
    regex = new RegExp(input.pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), flags);
  }

  const files = input.filename
    ? [safeLogPath(input.filename)]
    : listLogFiles();

  const results: SearchMatch[] = [];

  for (const filePath of files) {
    if (!fs.existsSync(filePath)) continue;

    const lines = readLines(filePath);
    for (let i = 0; i < lines.length; i++) {
      if (regex.test(lines[i])) {
        results.push({
          file: filePath,
          line_number: i + 1,
          content: lines[i],
        });
        if (results.length >= (input.max_results ?? 200)) {
          return results;
        }
      }
    }
  }

  return results;
}

// ---------------------------------------------------------------------------
// Tool: tail_logs
// ---------------------------------------------------------------------------

const TailLogsSchema = z.object({
  filename: z.string().describe("File name under /var/log/myapp/ to tail"),
  lines: z
    .number()
    .int()
    .positive()
    .optional()
    .default(100)
    .describe("Number of lines to return from the end. Default 100."),
});

type TailLogsInput = z.infer<typeof TailLogsSchema>;

interface TailResult {
  file: string;
  total_lines: number;
  returned_lines: number;
  content: string[];
}

function tailLogs(input: TailLogsInput): TailResult {
  const filePath = safeLogPath(input.filename);

  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const lines = readLines(filePath);
  const n = input.lines ?? 100;
  const tail = lines.slice(Math.max(0, lines.length - n));

  return {
    file: filePath,
    total_lines: lines.length,
    returned_lines: tail.length,
    content: tail,
  };
}

// ---------------------------------------------------------------------------
// Tool: parse_errors
// ---------------------------------------------------------------------------

const ParseErrorsSchema = z.object({
  filename: z.string().describe("File name under /var/log/myapp/ to parse"),
  since_line: z
    .number()
    .int()
    .nonnegative()
    .optional()
    .default(0)
    .describe("Start parsing from this 1-based line number (0 = from start). Useful for incremental reads."),
});

type ParseErrorsInput = z.infer<typeof ParseErrorsSchema>;

type Severity = "FATAL" | "ERROR" | "WARN" | "INFO" | "DEBUG" | "UNKNOWN";

interface ParsedLine {
  line_number: number;
  severity: Severity;
  content: string;
}

interface ParseErrorsResult {
  file: string;
  lines_scanned: number;
  counts: Record<Severity, number>;
  matches: ParsedLine[];
}

const SEVERITY_PATTERNS: Array<{ level: Severity; pattern: RegExp }> = [
  { level: "FATAL",   pattern: /\b(FATAL|CRITICAL|EMERG)\b/i },
  { level: "ERROR",   pattern: /\b(ERROR|ERR|EXCEPTION|Exception|Traceback|5\d\d )\b/i },
  { level: "WARN",    pattern: /\b(WARN|WARNING)\b/i },
  { level: "INFO",    pattern: /\b(INFO)\b/i },
  { level: "DEBUG",   pattern: /\b(DEBUG|TRACE)\b/i },
];

function classifySeverity(line: string): Severity | null {
  for (const { level, pattern } of SEVERITY_PATTERNS) {
    if (pattern.test(line)) return level;
  }
  return null;
}

function parseErrors(input: ParseErrorsInput): ParseErrorsResult {
  const filePath = safeLogPath(input.filename);

  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const lines = readLines(filePath);
  const startIndex = Math.max(0, (input.since_line ?? 0) - 1); // convert 1-based to 0-based

  const counts: Record<Severity, number> = {
    FATAL: 0,
    ERROR: 0,
    WARN: 0,
    INFO: 0,
    DEBUG: 0,
    UNKNOWN: 0,
  };
  const matches: ParsedLine[] = [];

  for (let i = startIndex; i < lines.length; i++) {
    const severity = classifySeverity(lines[i]);
    if (severity !== null) {
      counts[severity]++;
      // Only include WARN and above in matches to keep output manageable
      if (severity === "FATAL" || severity === "ERROR" || severity === "WARN") {
        matches.push({
          line_number: i + 1,
          severity,
          content: lines[i],
        });
      }
    }
  }

  return {
    file: filePath,
    lines_scanned: lines.length - startIndex,
    counts,
    matches,
  };
}

// ---------------------------------------------------------------------------
// MCP Server setup
// ---------------------------------------------------------------------------

const server = new Server(
  {
    name: "log-analyzer",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List tools handler
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "search_logs",
        description:
          "Search log files in /var/log/myapp/ for a pattern (regex or literal). Returns matching lines with file name and line number.",
        inputSchema: {
          type: "object",
          properties: {
            pattern: {
              type: "string",
              description: "Regex or literal string to search for",
            },
            filename: {
              type: "string",
              description:
                "Specific file under /var/log/myapp/ to search. Omit to search all .log files.",
            },
            case_sensitive: {
              type: "boolean",
              description: "Whether the search is case-sensitive. Default false.",
            },
            max_results: {
              type: "number",
              description: "Maximum matching lines to return. Default 200.",
            },
          },
          required: ["pattern"],
        },
      },
      {
        name: "tail_logs",
        description:
          "Return the last N lines of a log file in /var/log/myapp/ (like `tail -n`).",
        inputSchema: {
          type: "object",
          properties: {
            filename: {
              type: "string",
              description: "File name under /var/log/myapp/",
            },
            lines: {
              type: "number",
              description: "Number of lines to return from the end. Default 100.",
            },
          },
          required: ["filename"],
        },
      },
      {
        name: "parse_errors",
        description:
          "Scan a log file in /var/log/myapp/ and classify lines by severity (FATAL, ERROR, WARN, INFO, DEBUG). Returns counts and the matched lines for WARN and above.",
        inputSchema: {
          type: "object",
          properties: {
            filename: {
              type: "string",
              description: "File name under /var/log/myapp/",
            },
            since_line: {
              type: "number",
              description:
                "1-based line number to start from. Useful for incremental reads after a previous call.",
            },
          },
          required: ["filename"],
        },
      },
    ],
  };
});

// Call tool handler
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "search_logs": {
        const input = SearchLogsSchema.parse(args);
        const results = searchLogs(input);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  total_matches: results.length,
                  matches: results,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "tail_logs": {
        const input = TailLogsSchema.parse(args);
        const result = tailLogs(input);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "parse_errors": {
        const input = ParseErrorsSchema.parse(args);
        const result = parseErrors(input);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return {
      content: [{ type: "text", text: `Error: ${message}` }],
      isError: true,
    };
  }
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  // stderr so it doesn't interfere with stdio JSON-RPC
  process.stderr.write("mcp-log-server running on stdio\n");
}

main().catch((err) => {
  process.stderr.write(`Fatal: ${err}\n`);
  process.exit(1);
});
