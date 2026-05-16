---
title: Use a Recognised Tree/Object Walk Instead of Hand-Coded Recursion
impact: MEDIUM-HIGH
impactDescription: eliminates hand-rolled recursive descent with its accumulator and base-case bugs
tags: proc, recursion, traversal, walk
---

## Use a Recognised Tree/Object Walk Instead of Hand-Coded Recursion

When code recursively walks a tree, a nested object, a directory, or an AST, the engineer often invents a recursion structure from scratch — accumulators threaded through arguments, base cases mis-handling leaves, mutation-on-the-fly mixed with returned values. Libraries and stdlib utilities solve this once. `JSON.parse` + a generic walker, `lodash.cloneDeepWith`, `walk()` in Python, `Object.entries` recursion, or `traverse` in AST tools are all named tools for what feels like a one-off problem.

**Incorrect (a hand-coded recursive descent over a nested config object):**

```typescript
function findAllUrls(obj: any, found: string[] = []): string[] {
  if (typeof obj === 'string' && obj.startsWith('http')) {
    found.push(obj);
  } else if (Array.isArray(obj)) {
    for (const item of obj) {
      findAllUrls(item, found);
    }
  } else if (obj !== null && typeof obj === 'object') {
    for (const key of Object.keys(obj)) {
      findAllUrls(obj[key], found);
    }
  }
  return found;
  // The function has three implicit jobs: walk, filter, accumulate.
  // The accumulator threading is a classic source of "I get duplicates" bugs.
  // The null check is one of the few right things — the rest is one inlined library.
}
```

**Correct (use a generic walk; the predicate and the accumulator stay tiny):**

```typescript
import { traverse } from 'object-traversal'; // or equivalent

function findAllUrls(obj: unknown): string[] {
  const found: string[] = [];
  traverse(obj, ({ value }) => {
    if (typeof value === 'string' && value.startsWith('http')) found.push(value);
  });
  return found;
}
// The walker is library code, hardened. Your job is the predicate and the accumulator.
```

**If you really must roll your own — at least separate walking from inspecting:**

```typescript
function* walk(node: unknown): Generator<unknown> {
  yield node;
  if (Array.isArray(node)) for (const it of node) yield* walk(it);
  else if (node && typeof node === 'object') for (const v of Object.values(node)) yield* walk(v);
}

const findAllUrls = (obj: unknown) =>
  [...walk(obj)].filter((v): v is string => typeof v === 'string' && v.startsWith('http'));
// The walker is generic and reusable. The use-site has one job: filter.
```

**Other walks that get hand-coded:**

- Directory traversal → `fs.walk` (Node.js 20+), `os.walk` (Python), `find` (shell).
- AST traversal → `@babel/traverse`, `recast.visit`, `ts.forEachChild`.
- Deep object map (`{a: 1, b: {c: 2}}` → `{a: 2, b: {c: 4}}`) → `lodash.cloneDeepWith` with a customiser, or write the generator once and reuse.
- React fibre walk for testing → use `react-test-renderer` queries, not manual `children` recursion.

**When NOT to use this pattern:**

- The tree has a *very* specific shape and the walk semantics are domain-specific (e.g. "stop descending if you hit a `_hidden: true` node, but only on the third level") — the library may not parameterise that. Inline custom recursion is fine.
- The walk is performance-critical and the library overhead is measurable — measure first.

Reference: [MDN — Generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*)
