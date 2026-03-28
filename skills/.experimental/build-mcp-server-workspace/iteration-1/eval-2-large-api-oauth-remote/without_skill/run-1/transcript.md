# Execution Transcript

## 1. Task Understanding

The task was to design and scaffold an MCP (Model Context Protocol) server for a Salesforce integration with these specific constraints:

- **Large API surface**: hundreds of Salesforce objects and operations
- **Multi-tenant**: must work for any user who installs it, not just one org
- **Per-user OAuth**: each user authenticates with their own Salesforce org
- **Produce**: a full design recommendation AND scaffold code

The task required using only default knowledge (no skill files), operating as a baseline eval run.

---

## 2. Major Steps Taken

### Step 1: Determine the core architecture decision (Remote vs Local MCP server)

The first and most important decision was whether to build a local (stdio) or remote (HTTP) MCP server.

**Reasoning**: OAuth requires a redirect/callback URL, which is impossible with a local stdio process. Multi-user token storage requires server-side persistence. Therefore, a remote HTTP-based MCP server is the only viable approach. This single architectural decision cascades into all other choices.

### Step 2: Design the authentication flow

Salesforce uses OAuth 2.0 Web Server Flow. Key considerations:
- Connected App registration in Salesforce Setup
- `state` parameter for CSRF protection
- Instance URL returned per-org (critical — different orgs have different base URLs)
- Token refresh: access tokens expire in ~2 hours, refresh tokens are long-lived
- Sandbox vs production auth endpoints differ

### Step 3: Address the "hundreds of objects" problem

The naive approach — one MCP tool per Salesforce object — would create hundreds of tools that would overwhelm LLM context windows and be unmaintainable.

**Decision**: Design ~10 generic tools (query, create, update, delete, get, describe, list_objects, search, bulk_create, limits) where the Salesforce object name is a parameter. This keeps the MCP tool surface small and stable while covering all objects dynamically.

Supplemented by `salesforce_describe` and `salesforce_list_objects` tools that let the LLM discover the schema at runtime rather than needing it embedded in tool definitions.

### Step 4: Design token storage layer

Multi-user scenario requires per-session token storage with encryption at rest. Designed a token store abstraction with:
- Redis as primary (production, multi-instance)
- In-memory Map as fallback (development)
- AES-256-GCM encryption for stored tokens

### Step 5: Select the technology stack

- **Runtime**: Node.js + TypeScript (best MCP SDK support, jsforce ecosystem)
- **MCP SDK**: `@modelcontextprotocol/sdk` (official)
- **Salesforce client**: jsforce v2 (handles token refresh, REST/Bulk/Metadata APIs)
- **HTTP server**: Express (OAuth callback routes + MCP SSE transport)
- **Validation**: Zod (all tool inputs)

### Step 6: Write scaffold code

Produced a complete, runnable project scaffold:
1. `src/config.ts` — environment config with validation
2. `src/auth/token-store.ts` — encrypted token storage (Redis + memory fallback)
3. `src/auth/oauth.ts` — OAuth flow: build auth URL, callback handler, token refresh
4. `src/salesforce/client.ts` — jsforce connection factory with auto-refresh
5. `src/tools/index.ts` — MCP tool definitions (10 tools)
6. `src/tools/handlers.ts` — tool handler implementations
7. `src/server.ts` — MCP server + Express HTTP server + SSE transport
8. `package.json`, `tsconfig.json`, `.env.example`

### Step 7: Write the design recommendation document

Captured all architectural decisions, tradeoffs, security considerations, deployment options, and the rationale for each choice in `response.md`.

---

## 3. Tools Used

- **Bash**: Created output directory structure
- **Write**: Created all output files (response.md, scaffold code, transcript)

No file reading was needed (pure knowledge synthesis task). No skill files were consulted per the baseline eval instructions.

---

## 4. Outputs Produced

### Design Recommendation (`outputs/response.md`)
Full architectural design covering:
- Remote vs local server decision rationale
- Salesforce OAuth 2.0 Web Server Flow
- Generic tools pattern for large API surfaces
- Token storage design
- Stack recommendation (Node.js, jsforce, Redis)
- Project structure
- Critical implementation details (instance URL handling, pagination, error mapping, rate limiting)
- Deployment options (Cloudflare Workers, Railway, Docker)
- Security checklist
- Tradeoffs table

### Scaffold Code (`outputs/src/`)

| File | Purpose |
|---|---|
| `src/config.ts` | Environment variable management and validation |
| `src/auth/token-store.ts` | AES-256-GCM encrypted token storage with Redis/memory backends |
| `src/auth/oauth.ts` | OAuth flow: auth URL generation, callback handler, token exchange and refresh |
| `src/salesforce/client.ts` | jsforce Connection factory with token refresh and session caching |
| `src/tools/index.ts` | MCP tool schema definitions for all 10 Salesforce tools |
| `src/tools/handlers.ts` | Tool handler implementations with error handling and Zod validation |
| `src/server.ts` | Express + MCP SSE server, routes OAuth and MCP traffic |

### Supporting Files
- `package.json` — project dependencies
- `tsconfig.json` — TypeScript configuration
- `.env.example` — required environment variables documentation

---

## Key Design Insights

1. **Remote deployment is non-negotiable** for OAuth-based, multi-user MCP servers
2. **10 generic tools beat 400 object-specific tools** for LLM usability and maintainability
3. **Instance URL handling is the #1 Salesforce gotcha** — every org has a different base URL
4. **jsforce v2 handles token refresh** automatically via its `refreshFn` callback, reducing boilerplate
5. **Session-to-token binding** is the crux of the multi-user architecture; session ID in query params is the simplest approach
