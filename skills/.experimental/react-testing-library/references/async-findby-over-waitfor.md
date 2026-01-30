---
title: Use findBy Instead of waitFor + getBy
impact: CRITICAL
impactDescription: reduces async query code by 50%
tags: async, findBy, waitFor, best-practice
---

## Use findBy Instead of waitFor + getBy

`findBy*` queries are the preferred way to wait for elements. They combine `waitFor` with `getBy` in a single, readable call. Use `waitFor` only for non-element assertions.

**Incorrect (verbose and error-prone):**

```tsx
render(<UserList />)

await waitFor(() => {
  expect(screen.getByRole('listitem')).toBeInTheDocument()
})
// Verbose, and assertion inside waitFor is discouraged
```

**Correct (cleaner async query):**

```tsx
render(<UserList />)

const listItem = await screen.findByRole('listitem')
expect(listItem).toBeInTheDocument()
// Single call handles waiting, clear error if not found
```

**When to use waitFor:**
- Waiting for elements to disappear
- Asserting non-DOM conditions (state, mock calls)
- Multiple conditions that must be true together

```tsx
// Good use of waitFor - non-element assertion
await waitFor(() => {
  expect(mockFn).toHaveBeenCalledTimes(2)
})
```

Reference: [Common Mistakes - Using waitFor to wait for elements](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#using-waitfor-to-wait-for-elements-that-can-be-queried-with-find)
