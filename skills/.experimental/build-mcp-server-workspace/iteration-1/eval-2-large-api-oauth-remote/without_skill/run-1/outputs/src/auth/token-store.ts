import { createClient, RedisClientType } from "redis";
import { createCipheriv, createDecipheriv, randomBytes } from "crypto";
import { config } from "../config.js";

export interface TokenData {
  accessToken: string;
  refreshToken: string;
  instanceUrl: string;
  tokenType: string;
  issuedAt: number;
  orgId: string;
  userId: string;
}

// In-memory fallback for development
const memoryStore = new Map<string, string>();
let redisClient: RedisClientType | null = null;

async function getRedis(): Promise<RedisClientType | null> {
  if (redisClient) return redisClient;
  try {
    redisClient = createClient({ url: config.redis.url }) as RedisClientType;
    await redisClient.connect();
    return redisClient;
  } catch {
    console.warn("Redis unavailable, falling back to in-memory token store (not suitable for production)");
    return null;
  }
}

function encrypt(text: string): string {
  const key = Buffer.from(config.encryptionKey, "base64");
  const iv = randomBytes(16);
  const cipher = createCipheriv("aes-256-gcm", key, iv);
  const encrypted = Buffer.concat([cipher.update(text, "utf8"), cipher.final()]);
  const authTag = cipher.getAuthTag();
  return Buffer.concat([iv, authTag, encrypted]).toString("base64");
}

function decrypt(data: string): string {
  const key = Buffer.from(config.encryptionKey, "base64");
  const buf = Buffer.from(data, "base64");
  const iv = buf.subarray(0, 16);
  const authTag = buf.subarray(16, 32);
  const encrypted = buf.subarray(32);
  const decipher = createDecipheriv("aes-256-gcm", key, iv);
  decipher.setAuthTag(authTag);
  return decipher.update(encrypted) + decipher.final("utf8");
}

export async function storeTokens(sessionId: string, tokens: TokenData): Promise<void> {
  const encrypted = encrypt(JSON.stringify(tokens));
  const redis = await getRedis();
  if (redis) {
    await redis.setEx(`mcp:session:${sessionId}`, config.sessionTtl, encrypted);
  } else {
    memoryStore.set(sessionId, encrypted);
  }
}

export async function getTokens(sessionId: string): Promise<TokenData | null> {
  const redis = await getRedis();
  let encrypted: string | null = null;
  if (redis) {
    encrypted = await redis.get(`mcp:session:${sessionId}`);
  } else {
    encrypted = memoryStore.get(sessionId) ?? null;
  }
  if (!encrypted) return null;
  return JSON.parse(decrypt(encrypted)) as TokenData;
}

export async function deleteTokens(sessionId: string): Promise<void> {
  const redis = await getRedis();
  if (redis) {
    await redis.del(`mcp:session:${sessionId}`);
  } else {
    memoryStore.delete(sessionId);
  }
}
