---
title: Use clear() Before Retyping Input Values
impact: MEDIUM
impactDescription: prevents appending to existing values
tags: user, userEvent, clear, type, inputs
---

## Use clear() Before Retyping Input Values

`user.type()` appends to existing input values. To replace the value entirely, first call `user.clear()`.

**Incorrect (appends instead of replaces):**

```tsx
const user = userEvent.setup()
render(<EditableField defaultValue="Hello" />)

const input = screen.getByRole('textbox')
await user.type(input, 'World')

expect(input).toHaveValue('HelloWorld')
// Oops - wanted "World", got "HelloWorld"
```

**Correct (clear then type):**

```tsx
const user = userEvent.setup()
render(<EditableField defaultValue="Hello" />)

const input = screen.getByRole('textbox')
await user.clear(input)
await user.type(input, 'World')

expect(input).toHaveValue('World')
// Input value is exactly "World"
```

**Alternative - select all and type:**

```tsx
const input = screen.getByRole('textbox')
await user.tripleClick(input)  // Select all text
await user.type(input, 'New value')
// Replaces selected text
```

Reference: [userEvent - clear](https://testing-library.com/docs/user-event/utility#clear)
