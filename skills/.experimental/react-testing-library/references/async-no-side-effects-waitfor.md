---
title: Avoid Side Effects in waitFor
impact: CRITICAL
impactDescription: prevents actions from running multiple times
tags: async, waitFor, side-effects, interactions
---

## Avoid Side Effects in waitFor

Never perform user interactions or other side effects inside `waitFor`. The callback runs repeatedly until it passes, so side effects execute multiple times.

**Incorrect (click runs multiple times):**

```tsx
render(<Counter />)

await waitFor(() => {
  userEvent.click(screen.getByRole('button', { name: /increment/i }))
  expect(screen.getByText('Count: 1')).toBeInTheDocument()
})
// Button clicked on every retry - count keeps incrementing!
```

**Correct (interact first, then wait):**

```tsx
render(<Counter />)

const user = userEvent.setup()
await user.click(screen.getByRole('button', { name: /increment/i }))

expect(await screen.findByText('Count: 1')).toBeInTheDocument()
// Click once, wait for result
```

**Pattern for multiple interactions:**

```tsx
const user = userEvent.setup()

await user.type(screen.getByLabelText('Name'), 'John')
await user.click(screen.getByRole('button', { name: /submit/i }))

expect(await screen.findByText('Saved!')).toBeInTheDocument()
```

Reference: [Common Mistakes - Performing Side Effects in waitFor](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#performing-side-effects-in-waitfor)
