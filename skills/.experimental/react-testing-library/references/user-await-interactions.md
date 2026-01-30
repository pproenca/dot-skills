---
title: Always Await userEvent Interactions
impact: HIGH
impactDescription: prevents race conditions and ensures event completion
tags: user, userEvent, await, async
---

## Always Await userEvent Interactions

All `userEvent` methods return Promises. Forgetting to await them causes tests to proceed before interactions complete.

**Incorrect (missing await):**

```tsx
const user = userEvent.setup()
render(<Form />)

user.type(screen.getByLabelText('Name'), 'John')
user.click(screen.getByRole('button', { name: /submit/i }))

expect(screen.getByText('Submitted!')).toBeInTheDocument()
// Assertion runs before typing/clicking completes!
```

**Correct (properly awaited):**

```tsx
const user = userEvent.setup()
render(<Form />)

await user.type(screen.getByLabelText('Name'), 'John')
await user.click(screen.getByRole('button', { name: /submit/i }))

expect(await screen.findByText('Submitted!')).toBeInTheDocument()
// Interactions complete before assertion
```

**For sequential interactions, await each:**

```tsx
await user.click(screen.getByRole('button', { name: /add item/i }))
await user.type(screen.getByLabelText('Item name'), 'New item')
await user.keyboard('{Enter}')
```

Reference: [userEvent - Async Methods](https://testing-library.com/docs/user-event/intro#writing-tests-with-userevent)
