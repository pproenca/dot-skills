---
title: Use keyboard() for Special Keys
impact: MEDIUM
impactDescription: enables proper keyboard navigation testing
tags: user, userEvent, keyboard, special-keys
---

## Use keyboard() for Special Keys

Use `user.keyboard()` for special keys like Enter, Escape, Tab, and keyboard shortcuts. This properly simulates keyboard navigation.

**Incorrect (fireEvent for keyboard):**

```tsx
render(<SearchInput />)

const input = screen.getByRole('searchbox')
fireEvent.keyDown(input, { key: 'Enter', code: 'Enter' })
// Missing keyup, may not trigger submit handlers
```

**Correct (userEvent keyboard):**

```tsx
const user = userEvent.setup()
render(<SearchInput />)

const input = screen.getByRole('searchbox')
await user.type(input, 'search term')
await user.keyboard('{Enter}')
// Complete Enter key simulation
```

**Common key syntaxes:**

```tsx
await user.keyboard('{Enter}')     // Enter key
await user.keyboard('{Escape}')    // Escape key
await user.keyboard('{Tab}')       // Tab navigation
await user.keyboard('{Backspace}') // Delete character
await user.keyboard('{Control>}a') // Ctrl+A (select all)
await user.keyboard('{Shift>}{Tab}') // Shift+Tab
```

**For form submission:**

```tsx
await user.type(screen.getByLabelText('Search'), 'query{Enter}')
// Types "query" then presses Enter
```

Reference: [userEvent - keyboard](https://testing-library.com/docs/user-event/keyboard)
