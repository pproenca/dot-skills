---
title: Use jest-dom Matchers for DOM Assertions
impact: HIGH
impactDescription: 2-3× faster debugging with semantic error messages
tags: assert, jest-dom, matchers, assertions
---

## Use jest-dom Matchers for DOM Assertions

Use `@testing-library/jest-dom` matchers instead of generic Jest matchers. They provide clearer error messages and test semantic properties.

**Incorrect (generic Jest matchers):**

```tsx
render(<Button disabled>Submit</Button>)

const button = screen.getByRole('button')
expect(button.disabled).toBe(true)
expect(button.textContent).toBe('Submit')
expect(document.body.contains(button)).toBe(true)
// Unclear error messages, tests implementation
```

**Correct (jest-dom matchers):**

```tsx
render(<Button disabled>Submit</Button>)

const button = screen.getByRole('button')
expect(button).toBeDisabled()
expect(button).toHaveTextContent('Submit')
expect(button).toBeInTheDocument()
// Clear error: "Expected element to be disabled but it was enabled"
```

**Common jest-dom matchers:**
| Matcher | Use Case |
|---------|----------|
| `toBeInTheDocument()` | Element exists in DOM |
| `toBeDisabled()` | Form element is disabled |
| `toBeEnabled()` | Form element is enabled |
| `toBeVisible()` | Element is visible to user |
| `toHaveTextContent()` | Element contains text |
| `toHaveValue()` | Input has specific value |
| `toHaveClass()` | Element has CSS class |
| `toHaveFocus()` | Element has focus |

Reference: [jest-dom Custom Matchers](https://github.com/testing-library/jest-dom)
