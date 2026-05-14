---
title: Boolean Variables Use is/has/can Prefixes
impact: CRITICAL
impactDescription: prevents reading ambiguity at boolean call sites
tags: name, boolean, predicate, conditionals
---

## Boolean Variables Use is/has/can Prefixes

A boolean is a *predicate* — a question with a yes/no answer. Names like `isLoading`, `hasPermission`, `canEdit` read like questions at every call site (`if (isLoading) ...`), while bare names like `loading`, `permission`, `edit` could be states, callbacks, counts, or values. The prefix moves the type information into the name so the reader does not need to jump to the declaration.

**Incorrect (bare names — reader cannot tell from the call site what the type is):**

```tsx
// At `if (loading)`, is `loading` a boolean? A status string? A spinner component?
function OrderRow({ order }: { order: Order }) {
  const loading = useOrderStatus(order.id) === 'pending';
  const permission = useCurrentRole() === 'admin';
  const edit = !order.locked;

  if (loading) return <Skeleton />;
  return (
    <tr aria-disabled={!edit}>
      <td>{order.id}</td>
      {permission && <td><DeleteButton /></td>}
    </tr>
  );
}
```

**Correct (prefixed predicates — type and intent visible at every read):**

```tsx
// `if (isLoading)` reads as "if loading is true". No ambiguity, no jump-to-definition.
function OrderRow({ order }: { order: Order }) {
  const isLoading = useOrderStatus(order.id) === 'pending';
  const hasAdminAccess = useCurrentRole() === 'admin';
  const canEdit = !order.locked;

  if (isLoading) return <Skeleton />;
  return (
    <tr aria-disabled={!canEdit}>
      <td>{order.id}</td>
      {hasAdminAccess && <td><DeleteButton /></td>}
    </tr>
  );
}
```

**When NOT to apply this pattern:**
- When TypeScript already disambiguates at the boundary: a prop typed `loading: boolean` on a `<Button>` is fine because the prop name is read in concert with its type (`<Button loading={isFetching} />`). Many design systems use this convention to keep prop names short.
- Negated forms that read worse than a direct expression: `isNotEmpty(list)` is harder to read than `list.length > 0`. Prefer positive predicates or inline the expression.
- Domain words that are inherently boolean and would feel redundant prefixed: `published`, `archived`, `verified` are often clearer as-is on a model field (`order.published`) than `order.isPublished`, especially when serialized to/from an API that uses the bare form.

**Why this matters:** A predicate prefix turns every conditional into self-documenting code; the cost is one keystroke at declaration.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock on naming](https://www.totaltypescript.com/)
