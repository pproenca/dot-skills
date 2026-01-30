---
title: Avoid Empty waitFor Callbacks
impact: CRITICAL
impactDescription: prevents tests that pass without verifying anything
tags: anti, waitFor, empty-callback, async
---

## Avoid Empty waitFor Callbacks

Passing an empty callback or no callback to `waitFor` is meaningless. The test passes without waiting for or verifying anything.

**Incorrect (empty callback):**

```tsx
render(<AsyncForm />)

await userEvent.click(screen.getByRole('button', { name: /submit/i }))
await waitFor(() => {})
// Waits for nothing, passes immediately

expect(screen.getByText('Submitted!')).toBeInTheDocument()
// May fail if async operation hasn't completed
```

**Correct (wait for specific condition):**

```tsx
render(<AsyncForm />)

const user = userEvent.setup()
await user.click(screen.getByRole('button', { name: /submit/i }))

expect(await screen.findByText('Submitted!')).toBeInTheDocument()
// Properly waits for text to appear
```

**Alternative - wait for mock to be called:**

```tsx
const user = userEvent.setup()
await user.click(screen.getByRole('button', { name: /submit/i }))

await waitFor(() => {
  expect(mockSubmit).toHaveBeenCalled()
})
// Waits for actual condition
```

Reference: [Common Mistakes - Passing Empty Callback to waitFor](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#passing-an-empty-callback-to-waitfor)
