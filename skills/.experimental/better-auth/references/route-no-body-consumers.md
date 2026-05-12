---
title: Mount Auth Before Any Body-Parsing Middleware
impact: HIGH
impactDescription: prevents 400 "empty body" errors on POST sign-in / sign-up requests
tags: route, middleware, body-parser, express
---

## Mount Auth Before Any Body-Parsing Middleware

`auth.handler` (and the framework-specific helpers like `toNodeHandler`, `toNextJsHandler`) read the raw POST body to parse credentials, OAuth state, and verification tokens. Express's `express.json()`, custom logging middleware that calls `req.body`, and Next.js's default body parser all consume the stream. Once consumed, the auth handler reads an empty body and returns 400 — even though the route is mounted correctly.

**Incorrect (Express with body parser before auth):**

```typescript
import express from "express";
import { toNodeHandler } from "better-auth/node";
import { auth } from "./auth";

const app = express();
app.use(express.json());                        // ← consumes the body first
app.all("/api/auth/*", toNodeHandler(auth));    // ← handler sees empty stream
```

**Correct (auth handler BEFORE body parsers, or body parser scoped away from /api/auth):**

```typescript
import express from "express";
import { toNodeHandler } from "better-auth/node";
import { auth } from "./auth";

const app = express();

// Option 1: mount auth FIRST
app.all("/api/auth/*", toNodeHandler(auth));
app.use(express.json()); // for the rest of your API

// Option 2: scope body parser AWAY from /api/auth/*
app.use((req, res, next) => {
  if (req.path.startsWith("/api/auth")) return next();
  return express.json()(req, res, next);
});
app.all("/api/auth/*", toNodeHandler(auth));
```

**Incorrect (Next.js Pages Router with default body parser enabled):**

```typescript
// pages/api/auth/[...all].ts
import { toNodeHandler } from "better-auth/node";
import { auth } from "@/lib/auth";

export default toNodeHandler(auth);
// Missing config — Next parses JSON by default
```

**Correct (disable Next Pages body parsing for the auth route):**

```typescript
// pages/api/auth/[...all].ts
import { toNodeHandler } from "better-auth/node";
import { auth } from "@/lib/auth";

export default toNodeHandler(auth);

export const config = {
  api: { bodyParser: false }, // ← Better Auth reads the raw stream
};
```

**Warning:** The Next.js App Router (`route.ts`) does NOT pre-parse bodies — `toNextJsHandler` is safe by default. This issue only affects Pages Router and Node-style frameworks.

Reference: [Better Auth — Integrations: Node.js / Express](https://www.better-auth.com/docs/integrations/express)
