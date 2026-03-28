# Design Recommendation: Local Log Analysis MCP Server

## Phase 1 — Discovery Analysis

The task answers all Phase 1 questions upfront:

| Question | Answer |
|---|---|
| What does it connect to? | Local filesystem (`/var/log/myapp/`) |
| Who will use it? | Just me — personal use only |
| How many distinct actions? | 3 tools: search, tail, parse errors |
| Mid-call user input or rich display needed? | No — plain text/JSON output is sufficient |
| Auth? | None — local filesystem, no upstream service |

---

## Phase 2 — Deployment Model: Local stdio

**Recommendation: Local stdio (npx / personal tool)**

The skill's decision matrix is unambiguous here:

> "Just me / my team, on our machines → Local stdio is acceptable (easiest to prototype)"
> "Personal prototype → Local stdio / Whatever's fastest"

This server *must* touch the local machine — it reads `/var/log/myapp/`. A remote HTTP server cannot do this without a local agent relay. MCPB is the sanctioned distribution format, but since this is a personal tool (not distributed to anyone), local stdio is the right call — it's simpler to set up and there's no install-friction problem to solve.

**Register it in Claude Code with:**
```bash
claude mcp add --transport stdio myapp-logs -- npx tsx /path/to/server.ts
```

**Note:** The MCPB upgrade path exists if this ever needs distribution. For now, local stdio wins on simplicity.

---

## Phase 3 — Tool Design: One Tool Per Action (Pattern A)

3 tools, well within the < 15 threshold. Each gets a dedicated schema.

### Tool inventory

```
search_logs     — Search log files by pattern/regex. Returns matching lines with
                  filename, line number, and timestamp when parseable.
                  Does NOT follow symlinks — use tail_log for real-time output.

tail_log        — Return the last N lines of a log file. Use for recent activity.
                  Does NOT search — use search_logs for pattern matching.

parse_errors    — Scan one or all log files for error patterns (ERROR, WARN, FATAL,
                  stack traces). Returns structured summary grouped by severity and
                  message pattern. Use this for a quick health overview.
```

All three are read-only, no mutations → mark all with `readOnlyHint: true`.

### Security boundary

The server must refuse paths outside `/var/log/myapp/`. Validate every file path before opening it — this prevents path traversal even in a personal tool (good hygiene, and the skill's tool-design reference recommends tight schemas that prevent bad calls at runtime).

---

## Phase 4 — Framework: TypeScript SDK

**Official TypeScript SDK** (`@modelcontextprotocol/sdk`)

- Default choice, best spec coverage
- Node.js 18+ ships everywhere a personal dev machine runs
- Clean async/await, `zod` for schema validation

---

## Phase 5 — Scaffold

### Project structure

```
myapp-logs-mcp/
├── package.json
├── tsconfig.json
└── src/
    └── server.ts
```

### Install

```bash
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript @types/node tsx
```

### Register with Claude Code

```bash
claude mcp add --transport stdio myapp-logs -- npx tsx /absolute/path/to/myapp-logs-mcp/src/server.ts
```

Or add to `.claude/settings.json` for project-scoped registration:

```json
{
  "mcpServers": {
    "myapp-logs": {
      "command": "npx",
      "args": ["tsx", "/absolute/path/to/myapp-logs-mcp/src/server.ts"]
    }
  }
}
```

---

## Tool Schema Design Details

### `search_logs`

```
Parameters:
  pattern       string    Required. Regex or literal string to search for.
  file          string?   Optional. Specific filename in /var/log/myapp/.
                          If omitted, searches all .log files.
  max_results   int       1–500, default 50. Lines returned per file.
  case_sensitive bool     Default false.

Returns: JSON array of { file, line_number, line } objects.
Truncates and reports total count if results hit the cap.
```

### `tail_log`

```
Parameters:
  file          string    Required. Filename within /var/log/myapp/. No path traversal.
  lines         int       1–1000, default 100. Lines from end of file.

Returns: Last N lines as a text block with filename header.
```

### `parse_errors`

```
Parameters:
  file          string?   Optional. Specific filename. If omitted, scans all files.
  since_hours   int?      Optional. Limit to entries within N hours (requires parseable timestamps).

Returns: JSON with { summary: { error_count, warn_count, fatal_count },
                     top_patterns: [{ pattern, count, sample_line }],
                     recent_errors: [...] }
```

---

## Scaffold code is in `server.ts` (separate file).
