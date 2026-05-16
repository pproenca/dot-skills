---
title: Let Exceptions Propagate; Don't Catch What You Can't Handle
impact: MEDIUM
impactDescription: eliminates pass-through try/catch blocks that obscure failures
tags: defense, exceptions, try-catch, error-handling
---

## Let Exceptions Propagate; Don't Catch What You Can't Handle

A `try`/`catch` is a place where the program says, "I have a plan if this fails." When the `catch` block re-throws, logs and continues with `undefined`, returns `null`, or rewraps the error in a less informative one, the code is *pretending* to handle the error while actually swallowing or laundering it. The right form is to catch at the layer that can *do something* — typically the top of a request, a background job, or a UI boundary — and let everything below propagate.

**Incorrect (pass-through try/catch at every layer):**

```typescript
async function getUser(id: string): Promise<User | null> {
  try {
    return await db.users.findUnique({ where: { id } });
  } catch (err) {
    console.error(err);
    return null;                                          // caller can't tell "not found" from "DB down"
  }
}

async function getUserName(id: string): Promise<string | null> {
  try {
    const user = await getUser(id);
    return user?.name ?? null;
  } catch (err) {
    console.error(err);                                   // catching what cannot throw — getUser already swallowed
    return null;
  }
}

async function renderUserPage(id: string): Promise<string> {
  try {
    const name = await getUserName(id);
    return name ? `<h1>${name}</h1>` : '<h1>Not found</h1>';   // 'Not found' for DB outage too
  } catch (err) {
    console.error(err);                                   // never runs — already swallowed twice
    return '<h1>Error</h1>';
  }
}
// Three try/catches. Two are no-ops. One conflates two different failures. The actual
// failure (DB down) reaches the user as "Not found." Operators get console noise, not alerts.
```

**Correct (catch at the boundary that has a plan; trust above):**

```typescript
async function getUser(id: string): Promise<User | null> {
  return db.users.findUnique({ where: { id } });
  // Returns null when not found (the DB's contract).
  // Throws when the DB is unreachable — and that's the right answer for callers.
}

async function getUserName(id: string): Promise<string | null> {
  const user = await getUser(id);
  return user?.name ?? null;
}

async function renderUserPage(id: string): Promise<string> {
  try {
    const name = await getUserName(id);
    return name ? `<h1>${name}</h1>` : '<h1>Not found</h1>';
  } catch (err) {
    logger.error({ err, id }, 'render_user_page_failed');
    metrics.increment('page_error');
    return '<h1>Sorry, something went wrong.</h1>';
  }
}
// One try/catch — at the boundary that can decide between "user not found" (a real outcome)
// and "system error" (an alarm). The rest of the stack stays clean.
```

**Telltale anti-patterns:**

- `try { … } catch (e) { throw e; }` — does literally nothing.
- `try { … } catch (e) { throw new Error(e.message); }` — destroys the stack trace; doesn't add information.
- `try { … } catch { return undefined; }` — turns "actual error" into "caller's edge case." Two failure modes now look identical.
- `try { … } catch (e) { console.error(e); }` and then continues with garbage — the program is in a broken state but acts like everything's fine.
- `catch (e) { /* TODO: handle */ }` — three years old, still TODO. Either delete the catch or actually handle.

**Where catches earn their keep:**

- **HTTP boundary.** Translate exceptions into 4xx/5xx responses; log; emit metrics.
- **Background job runner.** Decide retry, dead-letter, or alert.
- **UI boundary (React error boundary, Vue errorCaptured).** Show a fallback; report.
- **A specific recoverable case** — e.g. `try { JSON.parse(s) } catch { /* fall back to raw */ }`. The catch is intentional and tight.

**When NOT to use this pattern:**

- A function that promises a *value or `null`* (not an exception) — wrapping a throwing call in `try { … } catch { return null }` is fine; it's the contract.
- Logging the error with full context *before* re-throwing is fine when the call site has information the boundary doesn't. But re-throw — don't swallow.

Reference: [The Pragmatic Programmer — Crashing Early](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/) (Hunt & Thomas)
