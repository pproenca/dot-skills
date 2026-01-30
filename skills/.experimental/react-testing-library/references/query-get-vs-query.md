---
title: Use getBy for Present Elements, queryBy for Absent
impact: CRITICAL
impactDescription: prevents false positives and unclear test failures
tags: query, getBy, queryBy, assertions
---

## Use getBy for Present Elements, queryBy for Absent

`getBy*` throws when no element is found (good for expected elements). `queryBy*` returns null (good for asserting absence). Using the wrong variant leads to confusing failures.

**Incorrect (queryBy for expected element):**

```tsx
render(<Alert message="Success!" />)

expect(screen.queryByRole('alert')).toBeInTheDocument()
// If element missing, assertion passes with null - confusing!
```

**Correct (getBy for expected element):**

```tsx
render(<Alert message="Success!" />)

expect(screen.getByRole('alert')).toBeInTheDocument()
// Throws immediately if element not found - clear failure
```

**For asserting absence, use queryBy:**

```tsx
render(<Dashboard showAlert={false} />)

expect(screen.queryByRole('alert')).not.toBeInTheDocument()
// Returns null when absent, assertion passes correctly
```

**Summary:**
| Variant | No Match | Use Case |
|---------|----------|----------|
| getBy | throws | Element should exist |
| queryBy | null | Element should NOT exist |
| findBy | throws (async) | Element will appear |

Reference: [Common Mistakes - Using query* Variants](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#using-query-variants-for-anything-except-checking-for-non-existence)
