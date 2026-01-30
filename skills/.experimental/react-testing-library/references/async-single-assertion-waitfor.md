---
title: Single Assertion in waitFor
impact: CRITICAL
impactDescription: faster failure detection, clearer error messages
tags: async, waitFor, assertions, performance
---

## Single Assertion in waitFor

Include only one assertion per `waitFor` callback. Multiple assertions cause the entire callback to retry until all pass or timeout, hiding which specific assertion failed.

**Incorrect (multiple assertions delay failure):**

```tsx
render(<UserProfile userId="123" />)

await waitFor(() => {
  expect(screen.getByText('John Doe')).toBeInTheDocument()
  expect(screen.getByText('john@example.com')).toBeInTheDocument()
  expect(screen.getByRole('img')).toHaveAttribute('src', '/avatar.png')
})
// If first assertion fails, waits full timeout before failing
```

**Correct (separate async queries):**

```tsx
render(<UserProfile userId="123" />)

expect(await screen.findByText('John Doe')).toBeInTheDocument()
expect(await screen.findByText('john@example.com')).toBeInTheDocument()
expect(await screen.findByRole('img')).toHaveAttribute('src', '/avatar.png')
// Each query waits independently, fails fast
```

**When waitFor with single assertion is appropriate:**

```tsx
// Waiting for state change reflected in mock
await waitFor(() => {
  expect(mockSave).toHaveBeenCalledWith({ name: 'John' })
})
```

Reference: [Common Mistakes - Multiple Assertions in waitFor](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#having-multiple-assertions-in-a-single-waitfor-callback)
