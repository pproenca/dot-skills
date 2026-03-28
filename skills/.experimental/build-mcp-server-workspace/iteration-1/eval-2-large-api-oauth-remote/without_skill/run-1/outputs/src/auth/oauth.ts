import { randomBytes } from "crypto";
import { Router } from "express";
import { config } from "../config.js";
import { storeTokens, type TokenData } from "./token-store.js";

// In-memory CSRF state store (use Redis in production)
const pendingStates = new Map<string, { sessionId: string; loginUrl: string; createdAt: number }>();

export function buildAuthUrl(sessionId: string, loginUrl?: string): string {
  const state = randomBytes(32).toString("hex");
  const baseUrl = loginUrl ?? config.salesforce.loginUrl;

  pendingStates.set(state, {
    sessionId,
    loginUrl: baseUrl,
    createdAt: Date.now(),
  });

  // Clean up states older than 10 minutes
  for (const [key, value] of pendingStates) {
    if (Date.now() - value.createdAt > 600_000) {
      pendingStates.delete(key);
    }
  }

  const params = new URLSearchParams({
    response_type: "code",
    client_id: config.salesforce.clientId,
    redirect_uri: config.salesforce.redirectUri,
    scope: "api refresh_token offline_access",
    state,
  });

  return `${baseUrl}/services/oauth2/authorize?${params.toString()}`;
}

export function createOAuthRouter(): Router {
  const router = Router();

  router.get("/oauth/callback", async (req, res) => {
    const { code, state, error, error_description } = req.query as Record<string, string>;

    if (error) {
      res.status(400).send(`OAuth error: ${error} - ${error_description}`);
      return;
    }

    const pending = state ? pendingStates.get(state) : null;
    if (!pending) {
      res.status(400).send("Invalid or expired OAuth state. Please reconnect.");
      return;
    }
    pendingStates.delete(state);

    try {
      const tokenResponse = await exchangeCodeForTokens(code, pending.loginUrl);
      await storeTokens(pending.sessionId, tokenResponse);
      res.send(`
        <html>
          <body>
            <h2>Salesforce connected successfully!</h2>
            <p>You can close this window and return to your AI assistant.</p>
            <p>Connected to: ${tokenResponse.instanceUrl}</p>
          </body>
        </html>
      `);
    } catch (err) {
      console.error("Token exchange failed:", err);
      res.status(500).send("Failed to exchange authorization code. Please try again.");
    }
  });

  return router;
}

async function exchangeCodeForTokens(code: string, loginUrl: string): Promise<TokenData> {
  const params = new URLSearchParams({
    grant_type: "authorization_code",
    code,
    client_id: config.salesforce.clientId,
    client_secret: config.salesforce.clientSecret,
    redirect_uri: config.salesforce.redirectUri,
  });

  const response = await fetch(`${loginUrl}/services/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params.toString(),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Token exchange failed: ${response.status} ${body}`);
  }

  const data = await response.json() as {
    access_token: string;
    refresh_token: string;
    instance_url: string;
    token_type: string;
    issued_at: string;
    id: string; // URL like https://login.salesforce.com/id/<orgId>/<userId>
  };

  // Extract org and user IDs from the identity URL
  const idParts = data.id.split("/");
  const userId = idParts[idParts.length - 1];
  const orgId = idParts[idParts.length - 2];

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    instanceUrl: data.instance_url,
    tokenType: data.token_type,
    issuedAt: parseInt(data.issued_at, 10),
    orgId,
    userId,
  };
}

export async function refreshAccessToken(sessionId: string, tokens: TokenData): Promise<TokenData> {
  const params = new URLSearchParams({
    grant_type: "refresh_token",
    refresh_token: tokens.refreshToken,
    client_id: config.salesforce.clientId,
    client_secret: config.salesforce.clientSecret,
  });

  // Use the instance URL's auth endpoint for refresh
  const loginUrl = tokens.instanceUrl.includes("sandbox") || tokens.instanceUrl.includes("test")
    ? "https://test.salesforce.com"
    : "https://login.salesforce.com";

  const response = await fetch(`${loginUrl}/services/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params.toString(),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Token refresh failed: ${response.status} ${body}`);
  }

  const data = await response.json() as {
    access_token: string;
    instance_url: string;
    issued_at: string;
  };

  const refreshed: TokenData = {
    ...tokens,
    accessToken: data.access_token,
    instanceUrl: data.instance_url ?? tokens.instanceUrl,
    issuedAt: parseInt(data.issued_at, 10),
  };

  await storeTokens(sessionId, refreshed);
  return refreshed;
}
