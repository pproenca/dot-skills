---
title: Log Through a Structured Logger You Own, Not `console.log`
impact: MEDIUM
impactDescription: enables structured logs with correlation IDs and severity routing
tags: mutate, logging, observability, structured
---

## Log Through a Structured Logger You Own, Not `console.log`

Build a logger in `@app/observability/logger` on top of `pino` and reach for it everywhere instead of `console.log`. `getLogger()` returns a structured logger that emits JSON with consistent field names and severity levels. `console.log` produces unstructured strings — they print to stdout, can't be filtered by severity, and lose all context (event name, account, tenant) the moment the request finishes. Structured logs are searchable and aggregatable; `console.log` output is not.

**Incorrect (unstructured logs lose context):**

```ts
'use server';
export const deleteAccountAction = authActionClient
  .inputSchema(DeleteAccountSchema)
  .action(async ({ ctx: { user } }) => {
    console.log(`Deleting account ${user.id}`);  // No structure, no correlation, no severity.
    // ... work ...
    console.error('Account deletion failed: ' + error.message);
    // Search for "Account deletion" in logs — you get every retry attempt
    // and have to correlate timestamps by hand.
  });
```

**Correct (structured logs with correlation + severity):**

```ts
'use server';
import { getLogger } from '@app/observability/logger';
import { getServiceRoleClient } from '@app/supabase/admin';

export const deleteAccountAction = authActionClient
  .inputSchema(DeleteAccountSchema)
  .action(async ({ ctx: { user } }) => {
    const logger = await getLogger();

    const ctx = {
      name: 'account.delete', // Stable event name for filtering.
      userId: user.id,        // Field for cross-action correlation.
    };

    logger.info(ctx, 'Deleting account...');

    try {
      const service = createDeletePersonalAccountService();
      await service.deletePersonalAccount({
        adminClient: getServiceRoleClient(),
        account: { id: user.id, email: user.email ?? null },
      });

      logger.info(ctx, 'Account deletion completed');
    } catch (error) {
      // Pass the error object so pino serialises the stack for the monitoring service.
      logger.error({ ...ctx, error }, 'Account deletion failed');
      throw error;
    }
  });
```

**You own the logger** (`packages/observability/src/logger.ts`) — a thin wrapper on `pino`, not a vendored helper:

```ts
import 'server-only';
import { pino, type Logger } from 'pino';

let instance: Logger | undefined;

export async function getLogger(): Promise<Logger> {
  // Async-initialised once: it reads runtime config, then returns a sync interface.
  return (instance ??= pino({
    level: process.env.LOG_LEVEL ?? 'info',
    base: { env: process.env.NODE_ENV },
  }));
}
```

**What lands in the log:**

```json
{
  "level": "info",
  "time": 1736974823000,
  "env": "production",
  "name": "account.delete",
  "userId": "user_xyz",
  "msg": "Deleting account..."
}
```

Filter by `name` (`account.delete`) or `userId` and you get every entry from that workflow. Pino does NOT auto-attach the proxy's `x-correlation-id`; if you want it on log lines, include it explicitly in `ctx` (read the header from the request or pass it down from the action).

**Convention for the `ctx` object:**

```ts
const ctx = {
  name: 'feature.action', // Stable identifier — '.create', '.delete', '.invite'.
  userId: user.id,        // Required for user-action correlation.
  accountId,              // Required for tenant correlation when relevant.
  // ... feature-specific identifiers (orderId, projectId, etc.)
};
```

Build it once at the top of the action. Every `logger.{info,warn,error}` call spreads it in: `logger.info({ ...ctx, attemptNumber }, 'Retrying')`. Reviewers can grep one `name` and see every log point in the action.

**Severity levels:**

| Method | Use for |
|--------|---------|
| `logger.info` | Successful workflow stages |
| `logger.warn` | Recoverable failures, policy denials, retried operations |
| `logger.error` | Unexpected errors and exceptions (pass the `error` object so pino serialises the stack) |
| `logger.debug` | Verbose tracing — filtered out at production log levels |

If you also want exception capture in a monitoring service (Sentry, Baselime, etc.), call it explicitly after logging — pino does not forward exceptions automatically.

**Never log secrets.** Pino doesn't redact — passing `{ password: parsedInput.password }` ships passwords to logs. Strip sensitive fields before passing the object in: `const { password, ...safe } = parsedInput; logger.info(safe, '...')`.

**Never use `console.log` for "temporary debugging."** Use `logger.debug` — it stays in dev, is stripped from production log levels, and survives review without an "I forgot to remove the console.log" PR.

**Why `await getLogger()`:** the logger is async-initialised (it reads runtime config). Calling it once at the top of an action gives you a sync interface for the rest of the handler.

Reference: [Pino structured logging](https://getpino.io/)
