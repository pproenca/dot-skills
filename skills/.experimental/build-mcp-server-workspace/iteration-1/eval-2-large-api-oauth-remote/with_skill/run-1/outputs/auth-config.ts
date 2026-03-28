/**
 * Salesforce OAuth Configuration
 *
 * This file documents the OAuth wiring for the Salesforce MCP server.
 * On Cloudflare Workers, use @cloudflare/workers-oauth-provider which handles
 * the CIMD/DCR endpoints, consent UI, and token issuance automatically.
 *
 * Spec alignment: MCP 2025-11-25
 *   - CIMD (Client ID Metadata Document) — SHOULD (preferred)
 *   - DCR (Dynamic Client Registration) — MAY (fallback)
 *
 * Key principle: The MCP bearer token (what Claude sends to your server) is
 * SEPARATE from the Salesforce access token (what your server uses to call
 * Salesforce). NEVER forward the MCP bearer to Salesforce.
 */

// ---------------------------------------------------------------------------
// Salesforce OAuth endpoints
// ---------------------------------------------------------------------------

export const SALESFORCE_OAUTH = {
  // Production orgs
  production: {
    authorizationUrl: "https://login.salesforce.com/services/oauth2/authorize",
    tokenUrl: "https://login.salesforce.com/services/oauth2/token",
    revokeUrl: "https://login.salesforce.com/services/oauth2/revoke",
  },
  // Sandbox orgs
  sandbox: {
    authorizationUrl: "https://test.salesforce.com/services/oauth2/authorize",
    tokenUrl: "https://test.salesforce.com/services/oauth2/token",
    revokeUrl: "https://test.salesforce.com/services/oauth2/revoke",
  },
} as const;

// Required OAuth scopes for this MCP server
// "api" covers all REST API access; "refresh_token" enables token refresh
export const REQUIRED_SCOPES = ["api", "refresh_token", "openid"];

// ---------------------------------------------------------------------------
// How to wire OAuth on Cloudflare Workers
// ---------------------------------------------------------------------------
//
// 1. Register a Salesforce Connected App:
//    - Go to Setup → App Manager → New Connected App
//    - Enable OAuth, set callback URL to: https://your-worker.workers.dev/oauth/callback
//    - Add scopes: api, refresh_token, openid
//    - Note the Consumer Key (client_id) and Consumer Secret (client_secret)
//
// 2. Store secrets in Cloudflare:
//    npx wrangler secret put SALESFORCE_CLIENT_ID
//    npx wrangler secret put SALESFORCE_CLIENT_SECRET
//    npx wrangler secret put COOKIE_SECRET          # random 32+ char string
//
// 3. Wrap your McpAgent with @cloudflare/workers-oauth-provider:
//    See the pattern below.
//
// ---------------------------------------------------------------------------

/**
 * Example wrangler.jsonc additions needed for OAuth + token storage:
 *
 * {
 *   "kv_namespaces": [
 *     { "binding": "TOKEN_STORE", "id": "YOUR_KV_NAMESPACE_ID" }
 *   ],
 *   "durable_objects": {
 *     "bindings": [{ "class_name": "SalesforceMCP", "name": "MCP_OBJECT" }]
 *   },
 *   "migrations": [
 *     { "new_sqlite_classes": ["SalesforceMCP"], "tag": "v1" }
 *   ]
 * }
 *
 * Create the KV namespace:
 *   npx wrangler kv namespace create TOKEN_STORE
 */

// ---------------------------------------------------------------------------
// OAuth AS Metadata (served at /.well-known/oauth-authorization-server)
// ---------------------------------------------------------------------------
// @cloudflare/workers-oauth-provider serves this automatically.
// Manual implementation would return:

export function buildOAuthASMetadata(baseUrl: string) {
  return {
    issuer: baseUrl,
    authorization_endpoint: `${baseUrl}/oauth/authorize`,
    token_endpoint: `${baseUrl}/oauth/token`,
    response_types_supported: ["code"],
    grant_types_supported: ["authorization_code", "refresh_token"],
    code_challenge_methods_supported: ["S256"],
    // CIMD: preferred per MCP spec 2025-11-25
    client_id_metadata_document_supported: true,
    // DCR: fallback for hosts without CIMD support
    registration_endpoint: `${baseUrl}/oauth/register`,
  };
}

// ---------------------------------------------------------------------------
// Token storage pattern (Cloudflare KV)
// ---------------------------------------------------------------------------

export interface StoredSalesforceToken {
  accessToken: string;
  refreshToken: string;
  instanceUrl: string;    // CRITICAL: per-user, varies by org
  issuedAt: number;       // Unix timestamp ms
  expiresIn: number;      // Seconds
}

/**
 * Key naming convention for KV:
 *   sf_session:{mcpSessionId}  →  StoredSalesforceToken (JSON)
 *
 * The MCP session ID from `extra.sessionId` binds the user's Salesforce
 * tokens to their MCP session. On session expiry, the tokens are effectively
 * orphaned and the user re-authenticates on next use.
 *
 * For production: add a secondary index keyed by user's Salesforce user ID
 * to reuse tokens across MCP sessions from the same user.
 */

export async function storeToken(
  kv: KVNamespace,
  mcpSessionId: string,
  token: StoredSalesforceToken,
): Promise<void> {
  await kv.put(
    `sf_session:${mcpSessionId}`,
    JSON.stringify(token),
    { expirationTtl: 24 * 60 * 60 }, // 24 hours — refresh before expiry
  );
}

export async function getToken(
  kv: KVNamespace,
  mcpSessionId: string,
): Promise<StoredSalesforceToken | null> {
  const raw = await kv.get(`sf_session:${mcpSessionId}`);
  return raw ? (JSON.parse(raw) as StoredSalesforceToken) : null;
}

export async function refreshIfNeeded(
  kv: KVNamespace,
  mcpSessionId: string,
  env: { SALESFORCE_CLIENT_ID: string; SALESFORCE_CLIENT_SECRET: string },
  isSandbox = false,
): Promise<StoredSalesforceToken | null> {
  const token = await getToken(kv, mcpSessionId);
  if (!token) return null;

  const ageMs = Date.now() - token.issuedAt;
  const expiresMs = token.expiresIn * 1000;
  // Refresh if within 5 minutes of expiry
  if (ageMs < expiresMs - 5 * 60 * 1000) return token;

  const endpoints = isSandbox ? SALESFORCE_OAUTH.sandbox : SALESFORCE_OAUTH.production;
  const res = await fetch(endpoints.tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: token.refreshToken,
      client_id: env.SALESFORCE_CLIENT_ID,
      client_secret: env.SALESFORCE_CLIENT_SECRET,
    }),
  });

  if (!res.ok) return null; // Force re-auth

  const refreshed = (await res.json()) as {
    access_token: string;
    instance_url: string;
    issued_at: string;
  };

  const updated: StoredSalesforceToken = {
    ...token,
    accessToken: refreshed.access_token,
    instanceUrl: refreshed.instance_url,
    issuedAt: parseInt(refreshed.issued_at, 10),
  };

  await storeToken(kv, mcpSessionId, updated);
  return updated;
}

// ---------------------------------------------------------------------------
// Audience validation (spec MUST — RFC 8707)
// ---------------------------------------------------------------------------
//
// The MCP spec requires validating that a bearer token was minted FOR this
// specific server, not just that it's a valid JWT.
//
// @cloudflare/workers-oauth-provider handles this automatically when configured
// with your server's audience. For manual implementations:
//
//   const payload = verifyJwt(bearerToken, publicKey);
//   if (!payload.aud.includes(MY_SERVER_AUDIENCE)) {
//     return new Response("Forbidden", { status: 403 });
//   }
//
// Token passthrough is EXPLICITLY FORBIDDEN by the MCP spec:
// The bearer token Claude sends must never be forwarded to Salesforce.
// Your server uses its own Salesforce access token (from the OAuth flow).
