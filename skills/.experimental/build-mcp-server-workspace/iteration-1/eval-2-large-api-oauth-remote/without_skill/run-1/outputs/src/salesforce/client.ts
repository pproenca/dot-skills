import jsforce from "jsforce";
import { getTokens, storeTokens, type TokenData } from "../auth/token-store.js";
import { refreshAccessToken } from "../auth/oauth.js";
import { config } from "../config.js";

// Cache connections per session (they hold connection state + describe cache)
const connectionCache = new Map<string, jsforce.Connection>();

export async function getSalesforceConnection(sessionId: string): Promise<jsforce.Connection> {
  const tokens = await getTokens(sessionId);
  if (!tokens) {
    throw new AuthRequiredError(sessionId);
  }

  // Reuse cached connection if still valid
  const cached = connectionCache.get(sessionId);
  if (cached && isTokenFresh(tokens)) {
    return cached;
  }

  // Refresh token if expired (Salesforce tokens last ~2 hours)
  let currentTokens = tokens;
  if (!isTokenFresh(tokens)) {
    currentTokens = await refreshAccessToken(sessionId, tokens);
  }

  const conn = new jsforce.Connection({
    instanceUrl: currentTokens.instanceUrl,
    accessToken: currentTokens.accessToken,
    version: config.salesforce.apiVersion,
    // jsforce will call this when it gets a 401
    refreshFn: async (_conn, callback) => {
      try {
        const refreshed = await refreshAccessToken(sessionId, currentTokens);
        callback(null, refreshed.accessToken);
      } catch (err) {
        callback(err as Error);
      }
    },
  });

  connectionCache.set(sessionId, conn);
  return conn;
}

function isTokenFresh(tokens: TokenData): boolean {
  // Salesforce tokens last 2 hours (7200 seconds); refresh if within 10 minutes of expiry
  const ageMs = Date.now() - tokens.issuedAt;
  return ageMs < (7200 - 600) * 1000;
}

export class AuthRequiredError extends Error {
  constructor(public sessionId: string) {
    super("Salesforce authentication required. Please connect your org first.");
    this.name = "AuthRequiredError";
  }
}

export function invalidateConnection(sessionId: string): void {
  connectionCache.delete(sessionId);
}
