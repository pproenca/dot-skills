---
title: Use waitForElementToBeRemoved for Disappearing Elements
impact: HIGH
impactDescription: prevents false positives when element never appeared
tags: async, waitForElementToBeRemoved, loading, disappear
---

## Use waitForElementToBeRemoved for Disappearing Elements

When waiting for elements to disappear (like loading spinners), use `waitForElementToBeRemoved`. It properly handles the element existing first, then being removed.

**Incorrect (queryBy with waitFor):**

```tsx
render(<DataLoader />)

await waitFor(() => {
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
})
// Passes immediately if loading text never appeared
```

**Correct (waitForElementToBeRemoved):**

```tsx
render(<DataLoader />)

await waitForElementToBeRemoved(() => screen.queryByText('Loading...'))
// Verifies element existed, then waits for removal
```

**Alternative with findBy then waitFor:**

```tsx
render(<DataLoader />)

// First confirm loading appears
const loadingText = await screen.findByText('Loading...')
// Then wait for it to disappear
await waitForElementToBeRemoved(loadingText)

expect(screen.getByText('Data loaded')).toBeInTheDocument()
```

**Tip:** The callback form re-queries on each check, while passing the element directly uses that reference.

Reference: [Testing Library - waitForElementToBeRemoved](https://testing-library.com/docs/dom-testing-library/api-async#waitforelementtoberemoved)
