---
title: Always Await findBy Queries
impact: CRITICAL
impactDescription: prevents race conditions and flaky tests
tags: async, findBy, await, promises
---

## Always Await findBy Queries

`findBy*` queries return Promises. Forgetting to await them causes tests to pass before assertions run, leading to false positives.

**Incorrect (missing await):**

```tsx
render(<AsyncComponent />)

const element = screen.findByRole('button')
expect(element).toBeInTheDocument()
// element is a Promise, not a DOM node!
// Test passes before element appears
```

**Correct (properly awaited):**

```tsx
render(<AsyncComponent />)

const element = await screen.findByRole('button')
expect(element).toBeInTheDocument()
// Waits for element, then asserts
```

**Also applies to findAllBy:**

```tsx
const items = await screen.findAllByRole('listitem')
expect(items).toHaveLength(3)
```

**Tip:** Configure ESLint to catch this:
```json
{
  "rules": {
    "testing-library/await-async-queries": "error"
  }
}
```

Reference: [Testing Library - Async Methods](https://testing-library.com/docs/dom-testing-library/api-async)
