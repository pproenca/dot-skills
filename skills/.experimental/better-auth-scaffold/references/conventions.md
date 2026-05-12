# Conventions

The templates in this skill enforce a small set of layout and configuration conventions. This document explains the WHY for each — so when you have to deviate (different framework, monorepo layout, exotic adapter), you can make an informed exception rather than copy-paste-and-hope.

---

## File Layout

### `lib/auth.ts` is server-only

Every template imports the auth instance from `@/lib/auth`. The file's first line is `import "server-only"` so any accidental client import becomes a build error.

**Why:** `BETTER_AUTH_SECRET`, OAuth client secrets, and database credentials all live on the auth instance. If a client component imports it (even just for a type), the bundler may pull the entire module into the browser bundle. `server-only` is the cheap insurance against that.

### `lib/auth-client.ts` is the only client-facing module

`createAuthClient` is the public surface. Use it everywhere on the client; never reach into `better-auth/react` directly from a component.

**Why:** When you later need to add `inferAdditionalFields`, `twoFactorClient`, or any other client plugin, there's one place to wire it. Components don't need to know about plugins.

### Database client at `@/db`, not duplicated

The `auth.ts` template imports `db` from `@/db`. We do NOT instantiate a second `Pool` or `PrismaClient` for Better Auth.

**Why:** Serverless cold starts open new database connections. Two clients = double the open connections per instance. At concurrency limits this manifests as random `too many connections` errors that look like auth bugs.

---

## Plugin Ordering

### `nextCookies()` is ALWAYS the last entry in `plugins: [...]`

Server Actions can't return a `Set-Cookie` header — they have to write through `next/headers`' cookie store. `nextCookies()` intercepts cookie writes from every preceding plugin and routes them to the Next API.

**Why:** If `nextCookies` runs before another plugin in the array, that later plugin's cookie writes are missed. Symptoms: `signIn.email` returns success, but the browser never receives the session cookie, and the user appears unauthenticated on the next request.

### Plugins pair: every server plugin gets its client counterpart

The templates enforce this for the `advanced` preset: `twoFactor` ↔ `twoFactorClient`, `magicLink` ↔ `magicLinkClient`.

**Why:** Server plugins add endpoints; client plugins add the typed method bindings (`authClient.twoFactor.enable`, `authClient.signIn.magicLink`). Forgetting the client side leaves you calling `authClient.signIn.magicLink({ email })` and getting a TypeError at runtime.

---

## Route Mounting

### `/api/auth/[...all]` — catch-all is mandatory

The folder MUST be named `[...all]` (or any other catch-all name; what matters is the bracket-dot-dot-dot syntax). The handler MUST be mounted via `toNextJsHandler(auth)` and exported as both `GET` and `POST`.

**Why:** Better Auth exposes dozens of sub-paths (`/api/auth/sign-in/social`, `/api/auth/callback/google`, `/api/auth/verify-email`, ...). Without the catch-all, every one of them 404s.

### App Router only

These templates target the App Router (`app/api/auth/[...all]/route.ts`). For Pages Router, use `pages/api/auth/[...all].ts` with `toNodeHandler(auth)` and `export const config = { api: { bodyParser: false } }`.

**Why:** App Router's `route.ts` doesn't pre-parse bodies; Pages Router does. Pre-parsing breaks the handler because Better Auth needs the raw stream.

---

## Middleware

### `middleware.ts` stays on Edge; full session check happens in pages

The middleware template only calls `getSessionCookie(request)` — a synchronous, cookie-presence check that runs on the Edge runtime. The actual session validation (which queries the database) happens in the page or route handler via `auth.api.getSession({ headers })`.

**Why:** Edge runtime can't run most DB drivers (`pg`, Prisma's binary engine, etc.). Calling `auth.api.getSession` from default-Edge middleware crashes at build or first request. Two valid alternatives:
- Opt the middleware into `runtime: "nodejs"` (Next 15.2+) — adds DB latency to every protected route.
- Use the cookie check + per-page validation pattern this template enforces — faster, but a stale cookie evades the check until the page validates.

The cookie check is enough for routing; the per-page check is the real enforcement.

---

## Configuration

### Env vars loaded via `process.env.*` (or a zod-validated `env` module)

Templates import OAuth secrets, `BETTER_AUTH_SECRET`, and `BETTER_AUTH_URL` from `env`, never inline.

**Why:** Inlining a secret in source means: (1) it lands in git history forever, (2) any `console.log(auth.options)` dumps it, (3) typo'd `auth.ts` imported from a client component leaks it to the browser bundle.

### `BETTER_AUTH_SECRET` ≥ 32 bytes, unique per environment

Generate with `openssl rand -base64 32`.

**Why:** The secret signs session cookies. Reusing dev's secret in prod is identical to having no secret. Rotating it without coordination invalidates every active session simultaneously.

### Per-environment `baseURL` set explicitly, not inferred

The template always sets `baseURL` from env. Defaults that infer from the request `Host` header are wrong behind proxies and on preview deploys.

**Why:** Inferred `baseURL` produces broken OAuth callbacks (`redirect_uri_mismatch`), password-reset emails that point at `localhost`, and verification links that 404.

---

## Sessions

### Sliding-window: `expiresIn: 7d`, `updateAge: 1d`

Templates set both. Active users stay logged in; inactive sessions expire on schedule; the database absorbs one update per user per day, not per request.

**Why:** Setting only `expiresIn` gives a hard fixed window — active users get booted mid-session. Setting `updateAge: 0` writes to the DB on every request — write amplification.

### `cookieCache.maxAge: 5 * 60` (5 minutes)

Templates enable `cookieCache`. Trade-off: ~100× reduction in session-table reads at the cost of up to 5 minutes' delay propagating session revocation across other tabs/devices.

**Why:** Every server component on a page calls `getSession()`. Without the cache, that's a SELECT on `session` per component per render. With the cache, the cookie is locally validated by signature for 5 minutes.

---

## Schema Generation

### Run `better-auth generate` after every config change, then run your ORM's migrate

`db/schema/auth.ts` is a PLACEHOLDER. The real schema comes from the CLI:

```bash
npx @better-auth/cli@latest generate     # writes the schema fragment
npx drizzle-kit generate                 # produces SQL migration
npx drizzle-kit migrate                  # applies it
```

**Why:** Plugins (twoFactor, organization, admin, passkey) each add tables and columns. If you add a plugin and don't regenerate, the plugin's endpoints fail at runtime with "table does not exist". Wire `generate` into your `predeploy` script.

---

## Shared Access Control

### `lib/permissions.ts` is imported by BOTH server and client

For multi-tenant scaffolds (organization + admin plugins), the `permissions.ts` template is the single source of truth for the access controller (`ac`) and the named roles. Both `lib/auth.ts` and `lib/auth-client.ts` import from it.

**Why:** Defining roles twice — once on the server, once on the client — guarantees drift. The server enforces stricter permissions than the client thinks exist, so the UI shows actions the server then rejects. Single import = no drift.
