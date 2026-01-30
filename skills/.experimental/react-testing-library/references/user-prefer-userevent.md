---
title: Use userEvent Over fireEvent
impact: HIGH
impactDescription: fires 4-10× more events per interaction, catches more bugs
tags: user, userEvent, fireEvent, interactions
---

## Use userEvent Over fireEvent

`userEvent` simulates complete user interactions with multiple events, while `fireEvent` only dispatches single DOM events. `userEvent` catches more bugs.

**Incorrect (single event, incomplete simulation):**

```tsx
render(<LoginForm />)

fireEvent.change(screen.getByLabelText('Email'), {
  target: { value: 'user@example.com' }
})
fireEvent.click(screen.getByRole('button', { name: /submit/i }))
// Missing focus, keydown, keyup events a real user triggers
```

**Correct (realistic user interaction):**

```tsx
render(<LoginForm />)

const user = userEvent.setup()
await user.type(screen.getByLabelText('Email'), 'user@example.com')
await user.click(screen.getByRole('button', { name: /submit/i }))
// Fires focus, keydown, keypress, input, keyup events
```

**Key differences:**
| Action | fireEvent | userEvent |
|--------|-----------|-----------|
| click | 1 event | focus + mousedown + mouseup + click |
| type | change event only | keydown + keypress + input + keyup per character |
| tab | N/A | full focus management |

Reference: [Testing Library - userEvent](https://testing-library.com/docs/user-event/intro)
