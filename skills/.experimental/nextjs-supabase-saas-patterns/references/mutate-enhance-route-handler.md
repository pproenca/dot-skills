---
title: Wrap API Routes with `enhanceRouteHandler`
impact: HIGH
impactDescription: prevents per-route auth/validation drift across handlers
tags: mutate, route-handler, api, validation
---

## Wrap API Routes with `enhanceRouteHandler`

`enhanceRouteHandler` from `@kit/next/routes` wraps a Next.js route handler with opt-in auth, CAPTCHA verification, Zod body parsing, and awaited params. The handler receives a typed `{ request, body, user, params }` argument. Without it, every route handler reimplements the same try/catch around `requireUser`, manually parses the body, checks the CAPTCHA token from a header, and converts validation failures into a consistent error response. Multiply that across 20 routes and you have 20 subtly different auth implementations.

**Incorrect (raw route handler — boilerplate everywhere):**

```ts
// app/api/projects/route.ts
export async function POST(req: NextRequest) {
  // Auth (might forget on the next handler).
  const client = getSupabaseServerClient();
  const { data } = await client.auth.getClaims();
  if (!data?.claims) return new Response('Unauthorized', { status: 401 });

  // Body parsing (could throw uncaught).
  let body;
  try {
    body = await req.json();
  } catch {
    return new Response('Invalid JSON', { status: 400 });
  }

  // Validation (different shape than other routes).
  if (!body.name || typeof body.name !== 'string') {
    return new Response(JSON.stringify({ error: 'name required' }), { status: 400 });
  }

  // ... the actual work ...
}
```

**Correct (one wrapper provides all of it):**

```ts
// app/api/projects/route.ts
import { enhanceRouteHandler } from '@kit/next/routes';
import * as z from 'zod';

const CreateProjectSchema = z.object({
  name: z.string().min(1).max(200),
  accountId: z.string().uuid(),
});

export const POST = enhanceRouteHandler(
  async ({ body, user, request, params }) => {
    // body is typed as z.output<typeof CreateProjectSchema> — fields auto-completed.
    // user is typed JWTUserData — already authenticated.
    const service = createProjectsService(getSupabaseServerClient());
    const project = await service.create({ ...body, userId: user.id });
    return NextResponse.json(project);
  },
  {
    schema: CreateProjectSchema,    // Validates body, returns 400 on failure.
    auth: true,                      // Default; calls requireUser, redirects on fail.
    captcha: false,                  // Set true to verify x-captcha-token.
  },
);
```

**What the wrapper does (`packages/next/src/routes/index.ts`):**

```ts
return async function routeHandler(
  request: NextRequest,
  routeParams: { params: Promise<Record<string, string>> },
) {
  // 1. CAPTCHA (if enabled): read x-captcha-token header, verify, 400 if missing/invalid.
  if (params?.captcha) { /* ... */ }

  // 2. Auth (if enabled, default true): requireUser → typed JWTUserData or redirect.
  const client = getSupabaseServerClient();
  if (params?.auth ?? true) {
    const auth = await requireUser(client);
    if (auth.error) return redirect(auth.redirectTo);
    user = auth.data;
  }

  // 3. Body validation: clone request, safeParseAsync, 400 with error.message on failure.
  if (params?.schema) {
    const json = await request.clone().json();
    const parsed = await params.schema.safeParseAsync(json);
    if (!parsed.success) return NextResponse.json({ error: parsed.error.message }, { status: 400 });
    body = parsed.data;
  }

  // 4. Invoke the handler with typed params.
  return handler({ request, body, user, params: await routeParams.params });
};
```

**Config matrix for common route types:**

| Route type | `auth` | `captcha` | `schema` | Notes |
|------------|--------|-----------|----------|-------|
| Authenticated mutation | `true` (default) | `false` | required | Most in-app API routes |
| Public form submission | `false` | `true` | required | Marketing forms, signups |
| Webhook (Stripe, DB) | `false` | `false` | optional | Verify signature inside the handler |
| Authenticated read | `true` (default) | `false` | optional | Reads without body |
| File upload | `true` (default) | `false` | optional | Schema doesn't fit multipart — parse inside |

**Params are awaited automatically.** Next 16's `params` is a Promise; the wrapper awaits it before passing to your handler so you read fields synchronously: `params.id` not `(await params).id`.

**Don't mix raw handlers and `enhanceRouteHandler` in the same project.** Pick one and apply universally. A new contributor opening `app/api/foo/route.ts` should find the same wrapping pattern as every other route.

**The validation error response shape:**

```json
{ "error": "name: String must contain at least 1 character" }
```

Keep this consistent across handlers — clients can rely on `error` being the message. If you need structured errors (field-level), build a small mapper from `z.ZodError`.

Reference: [next-safe-action equivalent for routes](https://github.com/TheEdoRan/next-safe-action) (the kit's `enhanceRouteHandler` is the route-handler analogue)
