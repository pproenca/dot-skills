# MCP Server for Salesforce: Design Recommendation

## Problem Statement

Build an MCP (Model Context Protocol) server for Salesforce that:
- Covers hundreds of objects and operations (large API surface)
- Works for any user who installs it (multi-tenant)
- Authenticates each user against their own Salesforce org via OAuth

---

## Recommended Architecture: Remote MCP Server with Per-User OAuth

### Core Decision: Remote vs. Local

For a multi-user, OAuth-integrated MCP server, **remote deployment is the right choice**, not a locally-installed stdio server.

**Why remote:**
- OAuth requires a callback URL — impossible with a pure local stdio server
- Token storage must be per-user and persistent
- One deployment serves all users
- Updates roll out instantly without reinstallation
- You control the runtime environment (secrets, caching, rate limiting)

**Transport:** HTTP with SSE (Server-Sent Events) or the newer Streamable HTTP transport introduced in MCP spec 2025-03-26.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  MCP Client (Claude, etc.)               │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTPS (MCP over HTTP+SSE)
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Remote MCP Server (your infra)              │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  MCP Layer  │  │  Auth Layer  │  │  SF API Layer │  │
│  │             │  │              │  │               │  │
│  │ Tool Router │  │ OAuth 2.0    │  │ jsforce /     │  │
│  │ Schema Gen  │  │ Token Store  │  │ REST API      │  │
│  │ Pagination  │  │ Refresh Mgr  │  │ Metadata API  │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────┘
                       │
                       ▼
           ┌───────────────────────┐
           │  User's Salesforce Org │
           │  (any org, any tenant) │
           └───────────────────────┘
```

---

## Authentication Flow

### Salesforce OAuth 2.0 Web Server Flow

```
1. User connects MCP server in their client
2. MCP server responds with auth_required + login URL
3. User visits: https://login.salesforce.com/services/oauth2/authorize
   ?response_type=code
   &client_id=<YOUR_CONNECTED_APP_CLIENT_ID>
   &redirect_uri=https://your-mcp-server.com/oauth/callback
   &scope=api refresh_token
4. User authenticates in Salesforce, grants permissions
5. Salesforce redirects to your callback with ?code=...
6. Server exchanges code for access_token + refresh_token
7. Tokens stored server-side, keyed by session/user ID
8. All subsequent MCP requests use stored tokens
```

**Key Salesforce OAuth details:**
- Register a Connected App in Salesforce Setup
- Request scopes: `api`, `refresh_token`, `offline_access`
- Salesforce access tokens expire in ~2 hours; always handle refresh
- Instance URL is returned in the token response — use it for all API calls (important: different orgs have different instance URLs, e.g. `https://mycompany.my.salesforce.com`)
- Sandbox orgs use `https://test.salesforce.com` for auth; allow users to specify

---

## Handling Hundreds of Objects: Dynamic Tool Generation

The key insight for a large API surface: **do not create one MCP tool per Salesforce object**. That leads to hundreds of tools which overwhelms LLM context and is unmaintainable.

### Recommended Pattern: Small Set of Generic Tools + Dynamic Schema

Define ~8-12 tools that cover all CRUD and query patterns, and make objects a parameter:

```
salesforce_query         -- SOQL query (free-form or templated)
salesforce_create        -- Create a record on any object
salesforce_update        -- Update a record by ID
salesforce_delete        -- Delete a record by ID
salesforce_get           -- Get a single record by ID
salesforce_describe      -- Describe an object's schema
salesforce_list_objects  -- List all available sObjects
salesforce_search        -- SOSL search across objects
salesforce_bulk_create   -- Bulk insert via Bulk API 2.0
salesforce_bulk_update   -- Bulk update via Bulk API 2.0
salesforce_run_flow      -- Invoke a Salesforce Flow
salesforce_apex_execute  -- Execute anonymous Apex (power users)
```

This gives the LLM a small, stable tool surface while supporting all objects.

### Tool Schema Example

```typescript
{
  name: "salesforce_query",
  description: "Execute a SOQL query against the Salesforce org. Use salesforce_describe first to understand available fields.",
  inputSchema: {
    type: "object",
    properties: {
      soql: {
        type: "string",
        description: "SOQL query string, e.g. SELECT Id, Name FROM Account WHERE CreatedDate = TODAY LIMIT 10"
      },
      explain: {
        type: "boolean",
        description: "If true, return query plan instead of results (for optimization)"
      }
    },
    required: ["soql"]
  }
}
```

### Dynamic Tool Augmentation (Optional Enhancement)

After OAuth, introspect the org's metadata to refine tool descriptions:
- Call `/services/data/vXX.0/sobjects/` to list all sObjects
- Inject object names into tool descriptions dynamically
- Cache describe results per org (they change infrequently)

---

## Token Storage

For a production deployment, store tokens in a secure backing store:

```
Session ID (from MCP connection) → {
  access_token,
  refresh_token,
  instance_url,      // e.g. https://myorg.my.salesforce.com
  token_type,
  issued_at,
  org_id,            // Salesforce org ID (from token introspection)
  user_id            // Salesforce user ID
}
```

**Storage options (ranked):**
1. Redis with TTL (best for multi-instance deployments)
2. Encrypted database (PostgreSQL with pgcrypto)
3. In-memory Map (dev/single-instance only, loses tokens on restart)

**Security:** Always encrypt tokens at rest. Use AES-256-GCM. Never log tokens.

---

## Stack Recommendation

### Runtime: Node.js + TypeScript

Rationale: Best MCP SDK support, Salesforce JS ecosystem (jsforce), strong typing.

### Key Dependencies

```json
{
  "@modelcontextprotocol/sdk": "^1.x",    // Official MCP SDK
  "jsforce": "^2.x",                       // Salesforce client (SOQL, REST, Bulk, Metadata)
  "express": "^4.x",                       // HTTP server + OAuth callback routes
  "redis": "^4.x",                         // Token storage
  "zod": "^3.x"                            // Input validation
}
```

### Why jsforce

- Handles OAuth token refresh automatically
- Supports REST API, Bulk API 2.0, Metadata API, Tooling API, Apex REST
- Battle-tested, TypeScript-friendly in v2

---

## Project Structure

```
salesforce-mcp/
├── src/
│   ├── server.ts              # MCP server entry point
│   ├── auth/
│   │   ├── oauth.ts           # OAuth flow handlers
│   │   ├── token-store.ts     # Token CRUD (Redis/memory)
│   │   └── middleware.ts      # Session → token resolution
│   ├── tools/
│   │   ├── index.ts           # Tool registry
│   │   ├── query.ts           # salesforce_query
│   │   ├── crud.ts            # create/update/delete/get
│   │   ├── describe.ts        # describe + list_objects
│   │   ├── search.ts          # SOSL search
│   │   ├── bulk.ts            # Bulk API 2.0
│   │   └── apex.ts            # Anonymous Apex execution
│   ├── salesforce/
│   │   ├── client.ts          # jsforce connection factory
│   │   └── cache.ts           # Schema/describe cache per org
│   ├── http/
│   │   ├── app.ts             # Express app (OAuth routes)
│   │   └── mcp-transport.ts   # SSE/HTTP transport setup
│   └── config.ts              # Environment config
├── package.json
├── tsconfig.json
└── .env.example
```

---

## Critical Implementation Details

### 1. Session-to-Token Binding

MCP connections carry a session identifier. You must map this to the stored tokens. Use a session cookie or a token embedded in the MCP server URL (e.g., `https://your-server.com/mcp?session=<session_id>`).

### 2. Instance URL is Per-Org

Never hardcode `https://login.salesforce.com` for API calls. After auth, use the `instance_url` from the token response for all API calls:

```typescript
const conn = new jsforce.Connection({
  instanceUrl: tokenData.instance_url,
  accessToken: tokenData.access_token,
});
```

### 3. API Version Pinning

Pin to a specific Salesforce API version. Use the latest stable (e.g., v62.0 as of early 2026). Allow override via environment variable.

### 4. Rate Limiting & Governance

Salesforce enforces API call limits per org. Implement:
- Request queuing (p-queue)
- Rate limit headers tracking (`Sforce-Limit-Info` header)
- Expose remaining API calls as a resource or in tool responses

### 5. Error Handling

Salesforce returns structured errors. Map them to MCP error responses:
```typescript
// Salesforce error format:
// [{ errorCode: "REQUIRED_FIELD_MISSING", message: "...", fields: [...] }]

// Map to MCP tool error:
return {
  isError: true,
  content: [{
    type: "text",
    text: `Salesforce error: ${err[0].errorCode} - ${err[0].message}`
  }]
};
```

### 6. Pagination

SOQL queries return max 2000 records. Implement cursor-based pagination using `nextRecordsUrl`:

```typescript
// Return pagination token in response so LLM can request more
{
  records: [...],
  totalSize: 5000,
  done: false,
  nextPageToken: "/services/data/v62.0/query/01g..."
}
```

---

## Deployment Options

### Option A: Cloudflare Workers (Recommended for scale)
- Native SSE support
- Global edge distribution
- Durable Objects for token storage
- Zero cold starts

### Option B: Railway / Render / Fly.io
- Simple Node.js deployment
- Pair with Redis for token storage
- Good for getting started quickly

### Option C: Self-hosted (Docker)
- Full control
- User runs their own instance
- Suitable for enterprise security requirements

---

## Security Checklist

- [ ] Never log access tokens or refresh tokens
- [ ] Encrypt tokens at rest (AES-256-GCM)
- [ ] Use PKCE in OAuth flow (Salesforce supports it)
- [ ] Validate `state` parameter to prevent CSRF in OAuth callback
- [ ] Set short session expiry, re-auth gracefully
- [ ] Restrict Connected App permissions to minimum required scopes
- [ ] Use Salesforce IP restrictions on the Connected App if possible
- [ ] Implement request validation (Zod) on all tool inputs
- [ ] Rate limit OAuth endpoints to prevent abuse

---

## Tradeoffs and Alternatives Considered

| Approach | Pros | Cons | Decision |
|---|---|---|---|
| One tool per SF object | Discoverable, self-documenting | Hundreds of tools, unmaintainable | Rejected |
| Generic CRUD tools | Small surface, flexible | LLM needs to know SOQL | **Chosen** |
| Local stdio server | Simple install | No OAuth callback URL possible | Rejected |
| Remote HTTP server | Full OAuth, multi-user | More infrastructure | **Chosen** |
| Salesforce SDK (official) | Supported | No Node.js SDK with full API coverage | jsforce preferred |

---

## Summary Recommendation

Build a **remote MCP server** deployed to cloud infrastructure (Cloudflare Workers or Railway) with:

1. **Salesforce OAuth 2.0 Web Server Flow** with PKCE, handling both production and sandbox orgs
2. **~10 generic tools** covering SOQL queries, CRUD operations, schema discovery, SOSL search, and Bulk API — avoiding the "one tool per object" antipattern
3. **jsforce v2** for the Salesforce client layer, which handles token refresh and supports all major Salesforce APIs
4. **Redis-backed token store** mapping session IDs to encrypted org credentials
5. **Dynamic schema enrichment** — after auth, describe the org's objects and inject that context into tool descriptions for better LLM guidance
