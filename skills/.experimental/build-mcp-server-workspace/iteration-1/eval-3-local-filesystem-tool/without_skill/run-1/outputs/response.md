# MCP Server: Log File Analyzer for /var/log/myapp/

## Design Recommendation

### Overview

Build a local MCP server in TypeScript using the `@modelcontextprotocol/sdk` package. The server runs as a stdio process and exposes three tools to Claude:

1. `search_logs` — search log files for a pattern (regex or literal)
2. `tail_logs` — read the last N lines of a log file
3. `parse_errors` — extract and classify error patterns from a log file

Because this is personal-use only (not published, not multi-user), the design prioritises simplicity: single file, minimal dependencies, stdio transport, and hardcoded base path (`/var/log/myapp/`).

---

### Architecture

```
Claude Desktop / Claude Code
        │
        │  stdio (stdin/stdout JSON-RPC)
        ▼
  mcp-log-server (Node.js process)
        │
        ▼
  /var/log/myapp/*.log
```

- Transport: **stdio** (simplest; no network port needed)
- Runtime: **Node.js** (via `ts-node` or compiled `dist/`)
- SDK: `@modelcontextprotocol/sdk` v1.x

---

### Tools Exposed

#### `search_logs`

Searches one or all log files under `/var/log/myapp/` for a pattern.

| Input | Type | Description |
|-------|------|-------------|
| `pattern` | string | Regex or literal string to search for |
| `filename` | string? | Specific file to search (omit to search all `.log` files) |
| `case_sensitive` | boolean? | Default `false` |
| `max_results` | number? | Cap on lines returned. Default `200` |

Returns matching lines with filename, line number, and content.

#### `tail_logs`

Returns the last N lines of a log file (equivalent to `tail -n`).

| Input | Type | Description |
|-------|------|-------------|
| `filename` | string | File name under `/var/log/myapp/` |
| `lines` | number? | Number of lines to return. Default `100` |

Returns the last N lines as an array.

#### `parse_errors`

Scans a log file and classifies lines by severity level. Recognises common patterns: `ERROR`, `WARN`, `FATAL`, `EXCEPTION`, stack trace lines, HTTP 5xx status codes.

| Input | Type | Description |
|-------|------|-------------|
| `filename` | string | File name under `/var/log/myapp/` |
| `since_line` | number? | Start from this line number (for incremental reads) |

Returns a summary object: counts per level, and an array of the matched lines.

---

### Security Notes

- The server is restricted to `/var/log/myapp/` by resolving and validating all paths before reading. Any `../` traversal attempt is rejected.
- No shell execution; all file operations use Node's `fs` module directly.
- stdio transport means the server is not reachable over the network.

---

### Registration in Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "log-analyzer": {
      "command": "node",
      "args": ["/path/to/mcp-log-server/dist/index.js"]
    }
  }
}
```

Or with `ts-node` for development:

```json
{
  "mcpServers": {
    "log-analyzer": {
      "command": "npx",
      "args": ["ts-node", "/path/to/mcp-log-server/src/index.ts"]
    }
  }
}
```

---

### File Structure

```
mcp-log-server/
├── package.json
├── tsconfig.json
└── src/
    └── index.ts        ← entire server in one file
```

---

### Dependencies

| Package | Purpose |
|---------|---------|
| `@modelcontextprotocol/sdk` | MCP server SDK |
| `zod` | Input schema validation (required by SDK tool definitions) |
| `typescript` | Dev dependency |
| `ts-node` | Dev: run without compiling |
| `@types/node` | Dev: Node.js type definitions |
