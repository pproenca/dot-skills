import "dotenv/config";

export const config = {
  port: parseInt(process.env.PORT ?? "3000", 10),

  // Salesforce Connected App credentials
  salesforce: {
    clientId: process.env.SF_CLIENT_ID ?? "",
    clientSecret: process.env.SF_CLIENT_SECRET ?? "",
    redirectUri: process.env.SF_REDIRECT_URI ?? "http://localhost:3000/oauth/callback",
    apiVersion: process.env.SF_API_VERSION ?? "62.0",
    loginUrl: process.env.SF_LOGIN_URL ?? "https://login.salesforce.com",
  },

  // Token encryption key (32 bytes, base64 encoded)
  encryptionKey: process.env.TOKEN_ENCRYPTION_KEY ?? "",

  // Redis for token storage
  redis: {
    url: process.env.REDIS_URL ?? "redis://localhost:6379",
  },

  // Session TTL in seconds (24 hours)
  sessionTtl: parseInt(process.env.SESSION_TTL ?? "86400", 10),
};

// Validate required config at startup
export function validateConfig(): void {
  const required = ["SF_CLIENT_ID", "SF_CLIENT_SECRET", "SF_REDIRECT_URI", "TOKEN_ENCRYPTION_KEY"];
  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(", ")}`);
  }
}
