# Common Scanner False Positives

Use this catalog to triage scanner output before recommending fixes. The scanner is intentionally conservative on the Python side (AST) and heuristic on every other language (regex + indent tracking). The patterns below produce findings that look suspicious but are not real complexity hotspots — dismiss them after a quick read.

## Iteration-shaped patterns that aren't loops

### Single predicate call

```ts
const selected = users.find(u => u.id === id);    // not a loop — one-pass O(n)
const ok = items.some(i => i.valid);              // not a loop — short-circuits O(n)
const total = nums.reduce((a, b) => a + b, 0);    // not a loop — single sweep O(n)
```

These were removed from `LOOP_RE` in v0.3.0, but legacy reports may still mention them. A single call to `find`/`findIndex`/`some`/`every`/`reduce` is O(n) — the only concern is when it is wrapped inside another loop, which the scanner already catches via the `forEach`/`map`/`filter`/`for`/`while` parent.

### `.map()` outside a render path

```ts
function normalizeIds(items: Item[]) {
  return items.map(i => i.id);    // pure data transform — not a render hotspot
}
```

`render-derived-work` is only relevant when the transform runs every render cycle and the input list is large. Outside a UI component, `.map()` is just the right tool.

## Render-path heuristic noise

### Constants adjacent to utility code

```ts
const MAX_RETRIES = 5;            // SCREAMING_SNAKE — fixed in v0.2.0
const HttpStatus = { OK: 200 };   // PascalCase namespace, not a component

export function pickActive(items) {
  return items.filter(i => i.active);
}
```

`RENDER_HINT_RE` requires a lowercase letter in the second position, so `MAX_RETRIES` and `HTTP_STATUS` no longer trigger render-path mode. If you still see `render-derived-work` near a constant declaration, check whether a true component definition is also in scope.

### Type aliases / interfaces

```ts
type UserId = string;
interface User { id: UserId; name: string }

export function pickFirst(users: User[]) {
  return users[0];
}
```

`type`/`interface` lines do not match the render hint pattern. If a finding lands on these, treat it as a stale leak from an earlier function in the same file.

## I/O-in-loop noise

### Redux / Zustand selectors

```ts
const ids = useSelector(selectActiveIds);
ids.map(id => useSelector(selectUserById, id));   // not a DB query — Redux selector
```

Redux selectors are pure functions over the store; calling them in a loop is not N+1. The scanner no longer flags `select*` calls. If you see one, it's likely from `Array.prototype.find()` being conflated — check the actual call shape.

### SQL builder DSLs

```ts
const q = db.select('*').from('users').where('active', true);
```

Method-chain SQL builders use `select()` and `where()` as fluent-API methods, not as the actual query execution. These were removed from `QUERY_IN_LOOP_RE` in v0.3.0. The real cost lives on `.exec()`, `.execute()` (when terminal), or the framework-specific method (`prisma.user.findMany`, `knex(...).then(...)`).

### React Testing Library

```tsx
const items = await screen.findAllByRole('listitem');
for (const item of items) {
  expect(item).toBeInTheDocument();
}
```

`screen.findBy*` is a query against the rendered DOM, not a database. It is also typically called once. Do not flag.

## Sort-in-loop noise

### Sort outside the loop

```ts
const sorted = [...items].sort((a, b) => a.id - b.id);
for (const item of sorted) {
  process(item);
}
```

The sort happens once, before the loop. The scanner uses an indent + function-boundary heuristic; if a `sort()` call sits at the same indent as the surrounding `for`, but lexically *above* it, the scanner can mis-place it. Inspect the actual line numbers.

### Stable user-defined comparator

```ts
items.sort((a, b) => priorityOrder[a.kind] - priorityOrder[b.kind]);
```

If `priorityOrder` is a stable lookup map, this is `O(n log n)` once and not the hot path. Do not flag unless the surrounding loop calls `sort()` repeatedly.

## When to override the scanner

The scanner emits HIGH severity for "structural" hotspots (`nested-loop`, `nested-or-callback-loop`, `sort-in-loop`, `io-or-query-in-loop`). Even at HIGH, ALL of the following must hold before recommending a fix:

1. The data size is large enough for complexity to matter (>~10³ for `O(n²) → O(n)`).
2. The path is hot (called on a per-request, per-render, or per-event basis).
3. The transformation preserves ordering, mutability, identity, and authorization (see Optimization Safety Checklist in SKILL.md).

If a finding fails any of these tests, dismiss it in the report with a one-line explanation rather than recommending a change.

## Reporting dismissals

In a report, label dismissed findings as:

```markdown
## DISMISSED nested-or-callback-loop
- Location: `Component.tsx:10`
- Reason: `.map()` over a small static array (length ≤ 5). Not a hotspot.
```

This keeps the audit trail honest — readers can see the scanner output AND the judgment applied to it.
