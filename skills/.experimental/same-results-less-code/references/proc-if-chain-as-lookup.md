---
title: Replace an if/elif Chain That Returns Different Constants With a Lookup
impact: MEDIUM-HIGH
impactDescription: reduces an N-branch if/elif to a single Map or object lookup
tags: proc, lookup-table, conditional, refactor
---

## Replace an if/elif Chain That Returns Different Constants With a Lookup

When an `if`/`else if` chain (or a `switch`) does nothing but pattern-match an input to a constant output — `'small' → 4`, `'medium' → 8`, `'large' → 16` — the chain is a runtime impersonation of an associative array. The chain is harder to read, harder to extend (every case needs another branch), and easy to leave incomplete (a value with no branch silently returns `undefined`). A lookup table makes the mapping the data structure it actually is.

**Incorrect (a control-flow ladder that's really a map):**

```typescript
function ironLevel(level: string): number {
  if (level === 'beginner') return 1;
  else if (level === 'intermediate') return 3;
  else if (level === 'advanced') return 7;
  else if (level === 'expert') return 15;
  else if (level === 'master') return 30;
  else throw new Error(`Unknown level: ${level}`);
}
// 6 lines of branching. Adding a new level → one new branch.
// Reading the mapping requires reading 6 statements.
```

**Correct (the mapping is data, not control flow):**

```typescript
const LEVEL_REQUIREMENTS: Record<Level, number> = {
  beginner: 1,
  intermediate: 3,
  advanced: 7,
  expert: 15,
  master: 30,
};

function ironLevel(level: Level): number {
  return LEVEL_REQUIREMENTS[level];
}
// The table reads at a glance. New level = one new line.
// If `Level` is a literal union type, TypeScript checks exhaustiveness for you.
```

**Variations:**

- Mapping `string → function` (a small dispatch): `Record<string, (x: T) => U>` and call `table[key](x)`.
- Mapping `enum → display label`: same shape; the table doubles as i18n input.
- Mapping `error code → message`: same shape; tests parameterise over rows.
- Mapping `permission → roles allowed`: `Record<Permission, Role[]>` and check membership.

**When NOT to use this pattern:**

- Each branch has *different control flow* (one returns, one throws, one logs) — that's real branching, not a table.
- Each branch's "constant" is actually computed from inputs not visible at table-build time — keep the function form, but consider making it a `Record<K, (input) => V>`.
- The chain has only two cases — a ternary is fine. Tables shine at three or more.

**Pair this with a discriminated union for exhaustiveness:**

```typescript
type Status = 'pending' | 'active' | 'cancelled' | 'completed';

const COLOR: Record<Status, string> = {
  pending:   'gray',
  active:    'green',
  cancelled: 'red',
  completed: 'blue',
};
// If you add 'paused' to the Status union and forget the table, TypeScript errors.
```

Reference: [Refactoring — Replace Conditional with Lookup](https://refactoring.com/) (Martin Fowler)
