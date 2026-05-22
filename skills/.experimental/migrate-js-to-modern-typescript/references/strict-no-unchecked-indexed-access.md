---
title: Enable noUncheckedIndexedAccess for Index Safety
impact: HIGH
impactDescription: prevents undefined-index crashes
tags: strict, nouncheckedindexedaccess, arrays, records
---

## Enable noUncheckedIndexedAccess for Index Safety

By default TypeScript types `arr[i]` and `record[key]` as the element type even when the index is out of range or the key is absent — a JavaScript footgun the type system otherwise ignores. `noUncheckedIndexedAccess` adds `| undefined` to indexed reads, forcing a presence check before use and catching crashes that survive every other strict flag.

**Incorrect (indexed access assumed present):**

```typescript
function firstTag(tagsByPost: Record<string, string[]>, postId: string): string {
  const tags = tagsByPost[postId] // typed string[], may be undefined
  return tags[0].toUpperCase() // two unchecked crashes hide on this line
}
```

**Correct (flag forces presence checks):**

```typescript
function firstTag(tagsByPost: Record<string, string[]>, postId: string): string {
  const tags = tagsByPost[postId] // now string[] | undefined
  const first = tags?.[0] // string | undefined
  return first ? first.toUpperCase() : "UNTAGGED"
}
```

**When NOT to use this pattern:**

- Hot loops over a known-dense array where the bounds are already proven; a
  single `const value = arr[i]!` after an explicit length check is clearer
  than threading `| undefined` through every access.

Reference: [tsconfig: noUncheckedIndexedAccess](https://www.typescriptlang.org/tsconfig/#noUncheckedIndexedAccess)
