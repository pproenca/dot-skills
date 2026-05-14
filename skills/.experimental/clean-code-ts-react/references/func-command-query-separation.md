---
title: Separate Commands from Queries
impact: CRITICAL
impactDescription: makes the call site read as either an action or a question, never both
tags: func, cqs, commands, queries
---

## Separate Commands from Queries

A function should either *do* something (a command, which changes state and returns `void`) or *answer* something (a query, which returns a value and changes nothing). Functions that do both — `if (setUserName(user, name)) { ... }` — read ambiguously: is the caller asking a question or performing an action? CQS (Command-Query Separation, Meyer) draws the line so each call site has a single meaning.

**Incorrect (function both mutates and returns a status — call site is ambiguous):**

```ts
// `setUserName` mutates AND returns success — the call site reads neither way naturally.
function setUserName(user: User, name: string): boolean {
  if (name.trim().length < 2) return false;
  user.name = name;
  return true;
}

// Reader: is this an `if (predicate)` or a command-with-status?
if (setUserName(currentUser, newName)) {
  showSuccess();
} else {
  showError('Name too short');
}
```

**Correct (split into a query and a command, OR return a discriminated union):**

```ts
// Option A: pure split — query first, then command.
function canRenameUser(user: User, name: string): boolean {
  return name.trim().length >= 2;
}
function renameUser(user: User, name: string): void {
  user.name = name;
}

if (canRenameUser(currentUser, newName)) {
  renameUser(currentUser, newName);
  showSuccess();
} else {
  showError('Name too short');
}

// Option B: encode CQS at the type level with a discriminated union Result.
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function renameUserSafely(user: User, name: string): Result<User, 'too-short'> {
  if (name.trim().length < 2) return { ok: false, error: 'too-short' };
  user.name = name;
  return { ok: true, value: user };
}

const result = renameUserSafely(currentUser, newName);
if (result.ok) showSuccess();
else showError(result.error);
```

**When NOT to apply this pattern:**
- React's `useState` returns `[value, setValue]` — a query AND a command setter as a tuple, deliberately, because the alternative (separate hooks) breaks the single-source-of-truth invariant.
- Database APIs commonly return both data and metadata in one call (`{ rows, affectedRowCount }`) — splitting forces two round-trips for information the driver already has.
- Stack/queue operations where the dual nature is the point: `Array.prototype.pop()`, `Map.prototype.delete()` return both a value and signal mutation in one atomic step; splitting them invites race conditions in concurrent contexts.

**Why this matters:** When a call site reads unambiguously as either a question or an action, bug surface shrinks and the function's contract becomes self-evident from its usage.

Reference: [Clean Code, Chapter 3: Functions — Command Query Separation](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Bertrand Meyer: Object-Oriented Software Construction](https://en.wikipedia.org/wiki/Command%E2%80%93query_separation)
