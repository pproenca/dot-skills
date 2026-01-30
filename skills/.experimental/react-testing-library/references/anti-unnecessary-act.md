---
title: Avoid Unnecessary act() Wrapping
impact: CRITICAL
impactDescription: eliminates noise and prevents masking real issues
tags: anti, act, react, warnings
---

## Avoid Unnecessary act() Wrapping

`render()` and `fireEvent` are already wrapped in `act()`. Adding extra wrappers adds noise and can mask actual async issues in your component.

**Incorrect (redundant act wrapping):**

```tsx
await act(async () => {
  render(<UserProfile />)
})

await act(async () => {
  fireEvent.click(screen.getByRole('button'))
})
// Unnecessary - these already use act internally
```

**Correct (let RTL handle act):**

```tsx
render(<UserProfile />)

const user = userEvent.setup()
await user.click(screen.getByRole('button'))
// RTL and userEvent handle act() automatically
```

**When act IS needed:**

```tsx
// Direct state updates outside RTL utilities
act(() => {
  result.current.increment()
})

// Manual timer advancement
act(() => {
  jest.advanceTimersByTime(1000)
})
```

**Note:** If you see "not wrapped in act(...)" warnings, the solution is usually to await async operations, not add more act() calls.

Reference: [Common Mistakes - Wrapping Things in act Unnecessarily](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#wrapping-things-in-act-unnecessarily)
