---
name: better-auth-scaffold
description: Use this skill whenever scaffolding a Better Auth setup in a Next.js (App Router) + Drizzle project — adding lib/auth.ts, lib/auth-client.ts, the /api/auth/[...all] route handler, middleware.ts, .env.example, and a permissions module. Produces convention-enforced templates for three plugin presets (minimal, social, advanced with twoFactor+magicLink). Trigger even when the user doesn't explicitly say "scaffold" — phrases like "set up Better Auth", "wire up auth", "initialize auth in this project", or "add auth to Next.js" should pull this in. Pairs with the `better-auth` skill, which covers the rules these templates encode.
---

# Better Auth Scaffold (Next.js + Drizzle)

Parameterized templates for bootstrapping a Better Auth setup in a Next.js App Router project using the Drizzle adapter. Each template enforces the conventions documented in [`references/conventions.md`](references/conventions.md) — file layout, plugin ordering, env handling, runtime selection.

## When to Apply

Reference these templates when:
- Starting a new Next.js project that needs authentication
- Adding Better Auth to an existing Next.js + Drizzle codebase
- Refactoring a partial Better Auth setup that's missing the catch-all route, middleware, or `nextCookies()` ordering
- Generating a per-feature variant (minimal, social, advanced) on top of an existing project

## Setup

### Required parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `preset` | no | `minimal` | `minimal` (email+password) \| `social` (adds Google + GitHub) \| `advanced` (social + twoFactor + magicLink) |
| `db_provider` | yes | — | `pg` \| `mysql` \| `sqlite` (Drizzle provider) |
| `app_name` | yes | — | Display name (becomes 2FA issuer in authenticator apps when preset=advanced) |

### Optional parameters

| Parameter | Default | Description |
|---|---|---|
| `auth_path` | `lib/auth.ts` | Server auth module path |
| `client_path` | `lib/auth-client.ts` | Client module path |
| `api_route_path` | `app/api/auth/[...all]/route.ts` | Catch-all route handler path |
| `protected_paths` | `["/dashboard"]` | Routes the middleware guards |

If `config.json` already exists with values, the skill uses those; otherwise it asks the user.

## Available Templates

| Template | Output File | When to emit |
|---|---|---|
| [`auth.ts.template`](assets/templates/auth.ts.template) | `lib/auth.ts` | Always |
| [`auth-client.ts.template`](assets/templates/auth-client.ts.template) | `lib/auth-client.ts` | Always |
| [`route.ts.template`](assets/templates/route.ts.template) | `app/api/auth/[...all]/route.ts` | Always |
| [`middleware.ts.template`](assets/templates/middleware.ts.template) | `middleware.ts` | When `protected_paths` is non-empty |
| [`env.template`](assets/templates/env.template) | `.env.example` | Always |
| [`db-schema-better-auth.ts.template`](assets/templates/db-schema-better-auth.ts.template) | `db/schema/auth.ts` | Always (stub — replace with output of `better-auth generate`) |
| [`db-index.ts.template`](assets/templates/db-index.ts.template) | `db/index.ts` | When the project has no Drizzle client yet |
| [`email.ts.template`](assets/templates/email.ts.template) | `lib/email.ts` | When `preset=advanced` (and the file doesn't already exist) |
| [`sign-in-page.tsx.template`](assets/templates/sign-in-page.tsx.template) | `app/sign-in/page.tsx` | When the project has no sign-in page (closes the middleware redirect loop) |
| [`permissions.ts.template`](assets/templates/permissions.ts.template) | `lib/permissions.ts` | Optional starter for org/admin plugin work |

## How to Use

1. **Resolve parameters.** Read `config.json` first; for any missing required parameter (`db_provider`, `app_name`), ask the user via `AskUserQuestion`.

2. **Render each template.** For each template file:
   - Read the template.
   - Substitute `{{placeholder}}` values (`{{app_name}}`, `{{db_provider}}`, etc.) with the resolved parameter values.
   - Apply `PRESET[...]` conditional blocks using these rules:
     1. Find every pair of marker lines matching `// PRESET[<tags>]` and `// /PRESET[<tags>]` (or `/* PRESET[...] */` / `# PRESET[...]` for non-JS files — same syntax, different comment style).
     2. Parse `<tags>` as a comma-separated list (e.g. `social,advanced`).
     3. If the chosen preset value is in `<tags>` → remove ONLY the two marker lines; keep the lines between them.
     4. If the chosen preset value is NOT in `<tags>` → remove the ENTIRE block including both marker lines.
     5. Markers may be nested (e.g. `PRESET[advanced]` inside `PRESET[minimal,social,advanced]`); process from inside out.
   - For Mustache-style iteration in `middleware.ts.template` (`// {{#protected_paths}}` ... `// {{/protected_paths}}`), repeat the lines between the markers once per item in the list, substituting `{{path}}` with each value.

3. **Write output files.** Before writing, check if the target file already exists:
   - If it doesn't exist → write it.
   - If it exists and is identical → no-op.
   - If it exists and differs → show a diff and ask the user (overwrite / merge / skip).

4. **Run the CLI sequence.** After all files are written:
   ```bash
   npx @better-auth/cli@latest generate
   npx drizzle-kit generate
   npx drizzle-kit migrate
   ```
   These commands replace the placeholder `db/schema/auth.ts` with the real schema and apply migrations.

5. **Print next steps.** Tell the user to:
   - Fill in `.env.local` (copy from `.env.example`)
   - Generate a secret: `openssl rand -base64 32`
   - Register OAuth redirect URIs with each provider console (for `social`/`advanced` presets)
   - Implement `lib/email.ts` to wire transactional email (for `advanced` preset)

## Conventions

Read [`references/conventions.md`](references/conventions.md) for the rationale behind every convention these templates encode. Highlights:

- `lib/auth.ts` is server-only (`import "server-only"`)
- `nextCookies()` is ALWAYS the last plugin in the array
- Middleware does a cookie-presence check only; real validation in pages
- All secrets via `process.env.*`, never inline
- Sliding-window sessions with `cookieCache` enabled

## Related Skills

- [`better-auth`](../better-auth/SKILL.md) — Library/API Reference with 42 rules covering setup, sessions, security, plugins, and migration. The templates here are one canonical realization of those rules; read the rule for the underlying reasoning when you need to deviate.

## Gotchas

See [`gotchas.md`](gotchas.md) — initialized empty, populated as we discover them.
