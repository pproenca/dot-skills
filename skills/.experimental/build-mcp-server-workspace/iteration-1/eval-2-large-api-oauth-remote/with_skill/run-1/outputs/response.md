# Salesforce MCP Server — Design Recommendation

## Summary of Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Deployment model | Remote streamable-HTTP | Cloud API + multi-user OAuth |
| Tool pattern | Search + Execute (hybrid) | Hundreds of objects/operations |
| Framework | TypeScript SDK (`@modelcontextprotocol/sdk`) | Default, best spec coverage |
| Auth | OAuth 2.0 via CIMD (preferred) + DCR fallback | User-specific Salesforce orgs |
| Host | Cloudflare Workers (recommended) or portable Express | Fastest deploy vs. portability |

---

## Phase 1 — Discovery Answers

Working from the stated requirements:

1. **Connects to:** Salesforce (cloud SaaS) — REST/Bulk/Composite API
2. **Who uses it:** Any user who installs it — each with their own Salesforce org
3. **How many actions:** Hundreds of objects, each with CRUD + query + metadata operations → well above the 30-tool ceiling
4. **Mid-call user input:** Not required for the core use case (no rich UI needed)
5. **Auth:** OAuth 2.0 — Salesforce uses the standard authorization-code flow with per-org endpoints

---

## Phase 2 — Deployment Model: Remote Streamable-HTTP

**Remote HTTP is the only viable option here.** The combination of:
- Multi-user OAuth (every user authenticates against their own org)
- Salesforce's per-org callback URLs
- Token storage and refresh needs
- Zero-install requirement for end users

...makes local stdio or MCPB a non-starter. OAuth redirects require a real hosted callback URL. Token storage per user requires server-side session state. You control upgrades centrally.

**Recommended hosting:** Cloudflare Workers with `@cloudflare/workers-oauth-provider` (fastest deploy, handles OAuth AS plumbing). Alternative: Express on Render/Railway/Fly if you need portability.

---

## Phase 3 — Tool Pattern: Search + Execute (Hybrid)

Salesforce has hundreds of standard objects (Account, Contact, Opportunity, Case, Lead, ...) plus custom objects per org. Each object supports at minimum: query, get, create, update, delete, describe. That's potentially 600+ operations for standard objects alone — nowhere near registerable as individual tools.

**The hybrid approach:**

1. **Dedicated tools for the 5 most common operations** — these get called constantly and benefit from tight schemas:
   - `soql_query` — Execute a SOQL SELECT statement
   - `get_record` — Fetch a single record by ID
   - `create_record` — Create a record of any object type
   - `update_record` — Update a record by ID
   - `describe_object` — Get field metadata for a Salesforce object

2. **Search + Execute for everything else** — bulk operations, metadata API, Flow, Reports, etc.:
   - `search_salesforce_actions` — Find available operations by intent
   - `execute_salesforce_action` — Run an operation by ID with params

**Why the hybrid:** SOQL queries and basic CRUD make up 90%+ of Salesforce API usage. Promoting them to dedicated tools means Claude gets tight schemas and precise descriptions without a discovery round-trip. The long tail (Apex, Metadata, Analytics, Bulk 2.0, etc.) stays behind search/execute.

---

## Phase 4 — Framework: TypeScript SDK

`@modelcontextprotocol/sdk` is the default choice:
- First to get new spec features (CIMD support, structured output, etc.)
- Best coverage of MCP 2025-11-25 spec
- Works identically on Cloudflare Workers (via `McpAgent`) and Express

---

## Phase 5 — Auth Architecture

Salesforce OAuth is a standard auth-code flow but has Salesforce-specific nuances:

1. **Salesforce Connected App** — You register one Connected App in your Salesforce Developer org and get a `consumer_key` + `consumer_secret`. This is your OAuth client for all users.
2. **Per-org authorization endpoint** — Salesforce users authenticate at `https://login.salesforce.com/services/oauth2/authorize` (or `https://test.salesforce.com` for sandboxes). Post-auth, the token response includes the user's `instance_url` — the actual API endpoint for their org.
3. **Token storage** — Store `access_token`, `refresh_token`, and `instance_url` per MCP session (or per user identity). On Cloudflare Workers, use Durable Objects or KV. On Express, use Redis keyed by session ID.

**CIMD is preferred** (MCP spec 2025-11-25 promoted it to SHOULD). Implement DCR as a fallback for hosts that haven't moved to CIMD yet.

**Token passthrough is forbidden** — never forward the bearer token Claude sends to Salesforce. The server uses its own Salesforce access tokens (from the OAuth flow), completely separate from the MCP bearer token.

---

## Scaffold Code

See the accompanying files in this directory:
- `server-workers.ts` — Cloudflare Workers deployment (fastest path)
- `server-express.ts` — Portable Express deployment
- `salesforce-catalog.ts` — Action catalog for the search+execute pattern
- `auth-config.ts` — OAuth configuration notes

---

## Deployment Checklist

- [ ] Register a Salesforce Connected App in your Developer Edition org
- [ ] Set callback URL to `https://your-worker.workers.dev/oauth/callback`
- [ ] Store `SALESFORCE_CLIENT_ID`, `SALESFORCE_CLIENT_SECRET` as secrets (never hardcoded)
- [ ] `POST /mcp` responds to `initialize` with server capabilities
- [ ] `tools/list` returns all 7 tools (5 dedicated + 2 search/execute)
- [ ] `/.well-known/oauth-authorization-server` serves valid AS metadata with `client_id_metadata_document_supported: true`
- [ ] `/.well-known/oauth-protected-resource` points to the AS metadata URL
- [ ] Bearer tokens validated with audience check (RFC 8707) on every `/mcp` request
- [ ] `instance_url` stored per user session (different orgs have different endpoints)
- [ ] Token refresh handled transparently before expiry
- [ ] CORS headers set
- [ ] `Origin` header validated on `/mcp` (DNS rebinding prevention — spec MUST)
- [ ] `MCP-Protocol-Version` header honored (return 400 for unsupported versions)
- [ ] Health check at `/health` separate from `/mcp`
- [ ] Smoke test: `npx @modelcontextprotocol/inspector --cli https://your-worker.workers.dev/mcp --transport http --method tools/list`

---

## User Connection

Once deployed, users connect by adding the URL — no install step:

```bash
# Claude Code
claude mcp add --transport http salesforce https://your-worker.workers.dev/mcp

# Claude Desktop / Claude.ai
# Settings → Connectors → Add custom connector → paste URL
```

The first tool call triggers the OAuth flow — Claude presents the auth URL, user authorizes in their browser, server stores the token, subsequent calls proceed silently.
