# Eval Transcript — eval-2-large-api-oauth-remote / with_skill / run-1

## 1. Task Understanding

The user asked: what is the best approach for an MCP server that wraps the Salesforce API, given that:
- Salesforce has hundreds of objects and operations (large API surface)
- Any user who installs it will authenticate with their own Salesforce org via OAuth (multi-user, user-specific orgs)

This is a design question + scaffold request. The task asks for both a full design recommendation and working scaffold code.

---

## 2. Execution Steps

### Step 1 — Read SKILL.md

Read the full skill file at:
`/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/build-mcp-server/SKILL.md`

The skill defines a 5-phase workflow: Discovery → Deployment model → Tool pattern → Framework → Scaffold. It explicitly says "do not start scaffolding until you have answers to the questions in Phase 1" but also says "if the user's opening message already answers them, acknowledge that and skip straight to the recommendation."

The task statement already answers all Phase 1 questions:
1. Connects to: Salesforce (cloud SaaS)
2. Who uses it: "any user who installs it" — multi-user, public distribution
3. How many actions: "hundreds of objects and operations" — large surface
4. Mid-call user input: not mentioned, assumed not needed
5. Auth: "OAuth" — explicitly stated

So I proceeded directly to recommendation.

### Step 2 — Read references/auth.md

Read to understand the OAuth patterns. Key findings:
- CIMD (Client ID Metadata Document) is PREFERRED per MCP spec 2025-11-25
- DCR (Dynamic Client Registration) is the MAY fallback
- Token passthrough is explicitly FORBIDDEN — MCP bearer != Salesforce access token
- RFC 8707 audience validation is a spec MUST
- Remote HTTP is strongly preferred over local stdio for OAuth
- `@modelcontextprotocol/sdk/server/auth` ships `mcpAuthRouter()`, `bearerAuth`, `proxyProvider` helpers

### Step 3 — Read references/tool-design.md

Read to understand the tool-design recommendations. Key findings:
- 30+ tools → switch to search + execute (context-window economics)
- Promote top 3-5 to dedicated tools (hybrid pattern)
- Write tight parameter schemas with `.describe()` on every field
- Use tool annotations (readOnlyHint, destructiveHint, openWorldHint, idempotentHint)
- Return MCP tool errors, not exceptions; include recovery hints
- Disambiguate sibling tools in descriptions

### Step 4 — Read references/remote-http-scaffold.md

Read to get the scaffold patterns for both TypeScript SDK (Express) and FastMCP (Python). Key findings:
- Search + Execute pattern uses `search_actions` + `execute_action`
- `rankActions()` can start as keyword matching, upgrade to embeddings later
- Stateless transport (fresh per request) is the default
- Deployment checklist includes CORS, Origin validation, health check, `MCP-Protocol-Version`

### Step 5 — Read references/deploy-cloudflare-workers.md

Read to understand the Cloudflare Workers path. Key findings:
- Bootstrap: `npm create cloudflare@latest -- name --template=cloudflare/ai/demos/remote-mcp-authless`
- `McpAgent` wraps `McpServer` — same tool API, different transport plumbing
- `@cloudflare/workers-oauth-provider` handles the OAuth AS side automatically
- Durable Objects used for session state
- Two commands to deploy: `npx wrangler dev` / `npx wrangler deploy`

### Step 6 — Read references/versions.md

Read to verify version-sensitive claims before writing output. Confirmed:
- CIMD/DCR status from MCP spec 2025-11-25 — verified 2026-03
- CF `agents` SDK and `McpAgent` API — verified 2026-03
- CF template path `cloudflare/ai/demos/remote-mcp-authless` — verified 2026-03

---

## 3. Decisions Made

| Decision | Choice | Reason |
|---|---|---|
| Deployment | Remote streamable-HTTP | Cloud API + multi-user OAuth — only viable option |
| Hosting | Cloudflare Workers (primary) + Express (portable) | Workers = fastest deploy; Express = portability |
| Tool pattern | Hybrid: 5 dedicated + search+execute | "Hundreds" = well over 30-tool ceiling; top 5 most common ops get dedicated tools |
| Framework | TypeScript SDK (`@modelcontextprotocol/sdk`) | Default choice, best spec coverage |
| Auth | CIMD preferred, DCR fallback | Per spec 2025-11-25; CF workers-oauth-provider handles automatically |

The 5 dedicated tools chosen:
1. `soql_query` — most common read operation
2. `get_record` — single-record fetch
3. `create_record` — most common write
4. `update_record` — most common mutation
5. `describe_object` — prerequisite for correct create/update

Everything else (bulk, metadata API, reports, flows, Apex, SOSL, delete) goes through `search_salesforce_actions` + `execute_salesforce_action`.

Delete was intentionally put in the catalog rather than as a dedicated tool — destructive operations benefit from the extra discovery step (forces Claude to be deliberate).

---

## 4. Skill Files Read and Influence

| File | What it influenced |
|---|---|
| `SKILL.md` | Overall workflow; confirmed Phase 1 answers already present; picked Remote HTTP from Phase 2 matrix ("Wrap a large SaaS API (50+ endpoints) → Remote HTTP + Search+Execute"); chose TypeScript SDK from Phase 4 table |
| `references/auth.md` | CIMD preferred + DCR fallback; token passthrough forbidden; audience validation MUST; token storage per MCP session; CF workers-oauth-provider recommendation |
| `references/tool-design.md` | 30+ tools → search+execute threshold; hybrid pattern (promote top 3-5); tight schemas with `.describe()`; tool annotations; error format with recovery hints; disambiguating descriptions |
| `references/remote-http-scaffold.md` | Search+execute code pattern; `rankActions()` implementation; stateless transport pattern; deployment checklist; user connection instructions |
| `references/deploy-cloudflare-workers.md` | Bootstrap command; `McpAgent` class pattern; `wrangler.jsonc` structure; secrets via wrangler; OAuth pointer to CF template |
| `references/versions.md` | Verified all version-sensitive claims before writing output |

---

## 5. Output Produced

All files saved to:
`/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/build-mcp-server-workspace/iteration-1/eval-2-large-api-oauth-remote/with_skill/run-1/outputs/`

| File | Contents |
|---|---|
| `response.md` | Full design recommendation: Phase 1-5 analysis, decision rationale, auth architecture, deployment checklist, user connection instructions |
| `server-workers.ts` | Complete Cloudflare Workers scaffold: all 7 tools (5 dedicated + 2 search/execute), McpAgent class, session/token integration points, health endpoint |
| `salesforce-catalog.ts` | Action catalog for search+execute: 9 actions covering bulk, reports, Apex, flows, metadata, SOSL, delete; `rankActions()` keyword ranker |
| `auth-config.ts` | OAuth configuration: SF endpoints (prod + sandbox), CIMD/DCR AS metadata builder, KV token storage pattern, refresh logic, audience validation notes |
| `server-express.ts` | Portable Express scaffold: same 7 tools, StreamableHTTPServerTransport, Origin validation, protocol version check, OAuth callback handler, health endpoint |
