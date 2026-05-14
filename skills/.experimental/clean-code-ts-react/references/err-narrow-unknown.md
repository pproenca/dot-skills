---
title: Always Narrow `unknown` in Catch Blocks
impact: HIGH
impactDescription: prevents secondary crashes from assuming caught values are `Error` instances
tags: err, unknown, type-narrowing, catch
---

## Always Narrow `unknown` in Catch Blocks

With `useUnknownInCatchVariables` (TS 4.4+), `catch` variables are typed `unknown` — because JavaScript lets you throw anything: strings, numbers, plain objects, even `undefined`. Reaching for `.message` or `.stack` without narrowing risks a `TypeError` inside your error handler, which masks the original error.

**Incorrect (assumes `e` is an `Error`):**

```ts
async function syncInvoice(invoiceId: string) {
  try {
    await stripeClient.invoices.retrieve(invoiceId);
  } catch (e) {
    // If `e` is `'rate_limited'` (a string thrown by some library),
    // `e.message` is `undefined` and `.toUpperCase()` crashes the handler.
    logger.error(e.message.toUpperCase());
  }
}
```

**Correct (narrow before use):**

```ts
async function syncInvoice(invoiceId: string) {
  try {
    await stripeClient.invoices.retrieve(invoiceId);
  } catch (e) {
    // Narrow once; safe everywhere below.
    const message = e instanceof Error ? e.message : String(e);
    logger.error(message);

    // For domain-specific handling, narrow on a known class:
    if (e instanceof StripeRateLimitError) {
      await scheduleRetry(invoiceId, e.retryAfter);
      return;
    }
    throw e;
  }
}
```

**When NOT to apply this pattern:**
- Codebases pre-TS 4.4 or with `useUnknownInCatchVariables: false` — the catch var defaults to `any`. Fix the tsconfig instead of working around it.
- Catch blocks that immediately re-throw without inspecting the error (`catch (e) { throw new WrappedError('sync failed', { cause: e }) }`) — `cause` is `unknown` on `ErrorOptions`, no narrowing needed.
- Top-level "log and rethrow" handlers where you genuinely just stringify and pass along — `String(e)` is sufficient without further narrowing.

**Why this matters:** A handler that crashes loses the original error AND adds a misleading new one. Narrow once, then handle.

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [TypeScript 4.4: `useUnknownInCatchVariables`](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-4.html)
