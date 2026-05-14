---
title: Delete Commented-Out Code
impact: HIGH
impactDescription: stops dead code from accumulating as cognitive tax on every future reader
tags: doc, dead-code, git, hygiene
---

## Delete Commented-Out Code

Commented-out code is dead weight that every future reader must evaluate: is it safe to restore? Why was it kept? Is it the canonical version or a stale draft? Git history is your archive — it remembers without polluting the working tree. Delete commented-out code; trust source control.

**Incorrect (alternate flow preserved as a comment, slowly rotting):**

```tsx
async function checkout(order: Order) {
  // const oldFlow = await legacyCheckout(order);
  // TODO: remove once Q2 migration is complete
  // if (oldFlow.status === 'pending') {
  //   await retryLegacy(oldFlow);
  // }

  const result = await processCheckout(order);

  // legacy fallback — keep until 2024-09
  // if (!result.ok) return legacyCheckout(order);

  return result;
}
```

Six months later, no one remembers if the legacy fallback is required, whether `legacyCheckout` still exists, or which path is authoritative.

**Correct (delete it; rely on git for archaeology):**

```tsx
async function checkout(order: Order) {
  // Pre-migration checkout flow lives in git history.
  // See: git log --oneline -- src/checkout.ts (commit abc123, "Remove legacy checkout")
  const result = await processCheckout(order);
  return result;
}
```

If the reference to the old commit is itself unnecessary, drop that too — the commit log is sufficient.

**When NOT to apply this pattern:**
- Temporary local diagnostics while actively debugging — fine to leave in your working copy, but delete before committing.
- Regression test cases deliberately disabled with an explicit reason (`it.skip('reproduces bug #4521 — re-enable when fixed', ...)`) — this is documented intent, not commented-out code.
- Template / example files in starter kits or documentation where commented lines are configuration hints for the user.

**Why this matters:** Source control already preserves history. Commented code in the working tree taxes every reader forever for a benefit `git log` already provides for free.

Reference: [Clean Code, Chapter 17: Smells and Heuristics — Commented-Out Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
