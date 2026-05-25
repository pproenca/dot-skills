---
title: Wrap Route Handlers in a Typed Handler That Owns Auth and Validation
impact: HIGH
impactDescription: prevents per-route auth/validation drift across handlers
tags: mutate, route-handler, api, validation
---

## Wrap Route Handlers in a Typed Handler That Owns Auth and Validation

Build one wrapper in `@app/next/route-handler` and route every API handler through it. The wrapper layers opt-in auth, optional CAPTCHA verification, Zod body parsing, and awaited params onto a plain Next.js Route Handler, then hands your handler a typed `{ request, body, user, params }` argument. A bare exported `POST` forces each route to re-implement the same try/catch around the auth check, manually parse the body, read the CAPTCHA header, and turn validation failures into a consistent response. Multiply that across twenty routes and you have twenty subtly different auth implementations — one of which will eventually forget the check.

**Incorrect (bare route handler — the same boilerplate, copied unevenly):**

```ts
// app/api/projects/route.ts
export async function POST(request: NextRequest) {
  // Auth — easy to forget on the next handler you add.
  const client = getServerClient();
  const { data } = await client.auth.getClaims();
  if (!data?.claims) return new Response('Unauthorized', { status: 401 });

  // Body parsing — could throw uncaught and surface as a 500.
  let body;
  try {
    body = await request.json();
  } catch {
    return new Response('Invalid JSON', { status: 400 });
  }

  // Validation — a different error shape than every other route.
  if (!body.name || typeof body.name !== 'string') {
    return new Response(JSON.stringify({ error: 'name required' }), { status: 400 });
  }

  // ... the actual work ...
}
```

**Correct (one wrapper supplies auth, validation, and typed params):**

```ts
// app/api/projects/route.ts
import { enhanceRouteHandler } from '@app/next/route-handler';
import { CreateProjectSchema } from '@app/projects/schema';
import { createProjectsService } from '@app/projects/server';
import { getServerClient } from '@app/supabase/server';
import { NextResponse } from 'next/server';

export const POST = enhanceRouteHandler(
  async ({ body, user }) => {
    // body is typed as z.output<typeof CreateProjectSchema> — fields auto-complete.
    // user is already authenticated, so the handler never re-checks the session.
    const service = createProjectsService(getServerClient());
    const project = await service.create({ ...body, userId: user.id });
    return NextResponse.json(project);
  },
  {
    schema: CreateProjectSchema, // Validates the body, returns 400 on failure.
    auth: true,                  // Default; runs the auth check, redirects on fail.
    captcha: false,              // Set true to verify the x-captcha-token header.
  },
);
```

**You own the wrapper** (`packages/next/src/route-handler.ts`) — a thin layer over a Next.js Route Handler, not a vendored helper:

```ts
import 'server-only';
import { NextResponse, type NextRequest } from 'next/server';
import { redirect } from 'next/navigation';
import type { ZodType } from 'zod';
import { requireUser } from '@app/supabase/require-user';
import { getServerClient } from '@app/supabase/server';
import { verifyCaptchaToken } from '@app/captcha/server';

export function enhanceRouteHandler<Body>(
  handler: (args: { request: NextRequest; body: Body; user: User; params: Record<string, string> }) => Promise<Response>,
  config: { schema?: ZodType<Body>; auth?: boolean; captcha?: boolean } = {},
) {
  return async function routeHandler(
    request: NextRequest,
    context: { params: Promise<Record<string, string>> },
  ) {
    if (config.captcha) {
      await verifyCaptchaToken(request.headers.get('x-captcha-token') ?? ''); // 400 if missing/invalid.
    }

    let user: User | undefined;
    if (config.auth ?? true) {
      const auth = await requireUser(getServerClient());
      if (auth.error) redirect(auth.redirectTo); // No session → sign-in route.
      user = auth.data;
    }

    let body = undefined as Body;
    if (config.schema) {
      const parsed = await config.schema.safeParseAsync(await request.clone().json());
      if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.message }, { status: 400 });
      }
      body = parsed.data;
    }

    // Next 16's params is a Promise — await it once so handlers read fields synchronously.
    return handler({ request, body, user: user!, params: await context.params });
  };
}
```

**Config matrix for common route types:**

| Route type | `auth` | `captcha` | `schema` | Notes |
|------------|--------|-----------|----------|-------|
| Authenticated mutation | `true` (default) | `false` | required | Most in-app API routes |
| Public form submission | `false` | `true` | required | Marketing forms, signups |
| Webhook (payment, DB) | `false` | `false` | optional | Verify the provider signature inside the handler |
| Authenticated read | `true` (default) | `false` | optional | Reads with no body |
| File upload | `true` (default) | `false` | optional | Schema doesn't fit multipart — parse inside |

**Params are awaited for you.** Next 16's `params` is a Promise; the wrapper awaits it before calling your handler, so you read `params.id` instead of `(await params).id` in every route.

**Don't mix bare handlers and the wrapper in one project.** Pick one and apply it universally. A contributor opening any `app/api/.../route.ts` should find the same wrapping pattern as every other route.

**Keep the validation error shape stable** so clients can rely on `error` being the message:

```json
{ "error": "name: String must contain at least 1 character" }
```

If you need field-level errors, build a small mapper from `z.ZodError` — but keep the top-level `error` consistent.

*Transferable:* the wrapper enforces "auth and validation happen in one place, before the handler runs." The example reads the session from Supabase, but the same wrapper works with any auth source — swap `requireUser` for your session check and the contract your handlers see (`{ request, body, user, params }`) stays identical.

Reference: [Next.js Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
