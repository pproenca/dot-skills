---
title: Enable rateLimit With Persistent Storage in Production
impact: HIGH
impactDescription: prevents credential-stuffing attacks and CPU exhaustion from brute-force sign-ins
tags: security, rate-limit, redis, brute-force
---

## Enable rateLimit With Persistent Storage in Production

Better Auth's `rateLimit` defends sign-in, password-reset, and OTP endpoints against credential stuffing. The default `storage: "memory"` works for a single-node dev environment but breaks down in production: every serverless instance gets its own counter (attacker hops instances to multiply the budget), and counters reset on every cold start. Use `storage: "secondary-storage"` backed by Redis/Upstash so the limit is enforced globally and survives restarts. Pair with `customRules` to apply tighter limits to expensive endpoints.

**Incorrect (memory storage on serverless):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  rateLimit: {
    enabled: true,
    window: 60,
    max: 100,
    // storage defaults to "memory" — per-instance, per-cold-start
  },
});
```

**Correct (persistent storage + per-path rules):**

```typescript
import { betterAuth, SecondaryStorage } from "better-auth";
import { Redis } from "@upstash/redis";

const redis = Redis.fromEnv();

const secondaryStorage: SecondaryStorage = {
  async get(key) {
    const v = await redis.get<string>(key);
    return v ?? null;
  },
  async set(key, value, ttl) {
    if (ttl) await redis.set(key, value, { ex: ttl });
    else await redis.set(key, value);
  },
  async delete(key) {
    await redis.del(key);
  },
};

export const auth = betterAuth({
  secondaryStorage,
  rateLimit: {
    enabled: true,
    storage: "secondary-storage",
    window: 60,
    max: 100,
    customRules: {
      "/sign-in/email":    { window: 60,  max: 5  }, // 5 / minute / IP — anti-brute force
      "/forget-password":  { window: 300, max: 3  }, // 3 / 5 min — anti-enumeration
      "/two-factor/verify":{ window: 60,  max: 10 },
    },
  },
});
```

**Common use cases:**
- Use the same Redis/Upstash instance for `cookieCache` invalidation, rate-limit, and any session-revocation broadcasts.
- Whitelist known good IPs (your offices, monitoring systems) by returning early in a custom hook before the rate-limit middleware runs.

**Warning:** Better Auth keys rate-limit buckets by IP. Behind a CDN or proxy, ensure the real client IP is forwarded (`X-Forwarded-For`) and your framework respects it — otherwise every request looks like it came from the proxy, and one user can DoS everyone.

Reference: [Better Auth — Rate Limit](https://www.better-auth.com/docs/concepts/rate-limit)
