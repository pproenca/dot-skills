# MCP Server for Internal Issue Tracker

## Design Recommendation

### Phase 1: Discovery Summary

Based on what you've told me:

| Question | Answer | Implication |
|---|---|---|
| What does it connect to? | Internal REST API (~8 endpoints) | Remote HTTP server |
| Who uses it? | Team of 5 engineers | Flexible — but remote HTTP is still cleaner |
| How many actions? | ~8 | Pattern A: one tool per action |
| Mid-call user input needed? | No | Plain tool returning JSON |
| Auth? | API key, no OAuth | Simple env var, no auth infrastructure needed |

### Phase 2: Deployment Model — Remote Streamable-HTTP

**Recommendation: Remote streamable-HTTP MCP server** (hosted internally, e.g. Render, Railway, Fly.io, or your own server).

Even for a 5-person team, remote HTTP wins over local stdio because:
- One deployment, one config update — all 5 engineers connect to the same URL
- You push updates without anyone reinstalling anything
- No "it works on my machine" runtime version mismatches
- Can be hosted inside your network/VPN for security

If you genuinely need to prototype first on a single machine, local stdio is a valid stepping stone — but plan to migrate.

### Phase 3: Tool Pattern — One Tool Per Action

With ~8 endpoints, **Pattern A (one tool per action)** is the right call. Each tool gets a tight description and schema. The entire tool list fits comfortably in Claude's context window with room to spare.

Suggested tools based on your description:

| Tool name | Annotation | Description guidance |
|---|---|---|
| `create_issue` | `openWorldHint: true` | Write tool; include what fields are required |
| `update_issue` | `openWorldHint: true`, `idempotentHint: true` | Clarify which fields are updatable |
| `search_issues` | `readOnlyHint: true` | Say what fields it searches (title? body? tags?) |
| `get_issue` | `readOnlyHint: true` | Disambiguate from search — "use this when you have the ID" |
| `add_comment` | `openWorldHint: true` | One-liner; note it requires an issue ID |
| `list_issues` | `readOnlyHint: true` | If different from search (unfiltered list) |
| `close_issue` / `change_status` | `openWorldHint: true` | If separate from update_issue |
| `delete_issue` | `destructiveHint: true` | Explicit destructive annotation |

### Phase 4: Framework — TypeScript SDK

**Recommendation: Official TypeScript SDK** (`@modelcontextprotocol/sdk`).

Best spec coverage, first to get new MCP features, strong typing. If your team already writes TypeScript, this is a natural fit.

Python (FastMCP) is equally valid if your team prefers it — the wire protocol is identical.

### Auth Strategy

Pass the API key as an environment variable (`ISSUE_TRACKER_API_KEY`). Inject it at deploy time via your host's secret manager. Never hardcode it.

Users connect to the MCP server URL; they never touch the upstream API key. This is a significant security improvement over distributing the key to 5 machines.

```
Claude Code / Desktop → MCP Server (holds API key) → Internal Issue Tracker API
```

---

## Scaffold Code

See `server.ts` and `package.json` in this directory for the complete scaffold.

### Quick start

```bash
npm install
ISSUE_TRACKER_API_KEY=your_key ISSUE_TRACKER_BASE_URL=https://your-tracker.internal npx tsx src/server.ts
```

Then smoke-test:

```bash
# Interactive inspector
npx @modelcontextprotocol/inspector
# → Streamable HTTP → http://localhost:3000/mcp → Connect

# CLI smoke test
npx @modelcontextprotocol/inspector --cli http://localhost:3000/mcp \
  --transport http --method tools/list
```

### Connect your team

Once deployed to e.g. `https://issue-tracker-mcp.internal`:

```bash
# Each engineer runs once:
claude mcp add --transport http issue-tracker https://issue-tracker-mcp.internal/mcp
```

Or add to a shared `.mcp.json` in your repo root so it's automatic for everyone:

```json
{
  "mcpServers": {
    "issue-tracker": {
      "type": "http",
      "url": "https://issue-tracker-mcp.internal/mcp"
    }
  }
}
```

---

## Key design decisions applied

1. **Tight schemas everywhere** — enums for status fields, regex for IDs if your tracker has a known format, explicit `.describe()` on every parameter.
2. **Descriptions disambiguate siblings** — `search_issues` vs `get_issue` each explain when to use the other.
3. **Error returns include next steps** — when an issue isn't found, the error tells Claude to call `search_issues` first.
4. **Read/write annotations** — all read-only tools tagged `readOnlyHint: true` so Claude Code can auto-approve them without confirmation prompts.
5. **`instructions` field on the server** — nudges Claude to search before fetching by ID (since IDs aren't guessable).

---

## Deployment checklist

- [ ] `POST /mcp` responds to `initialize` with server capabilities
- [ ] `tools/list` returns all 8 tools with complete schemas
- [ ] Errors return structured MCP errors, not HTTP 500s
- [ ] `ISSUE_TRACKER_API_KEY` loaded from env, never hardcoded
- [ ] `Origin` header validated on `/mcp` (DNS rebinding prevention)
- [ ] Health check at `GET /health` separate from `/mcp`
- [ ] Smoke-tested with MCP Inspector before sharing URL with team
