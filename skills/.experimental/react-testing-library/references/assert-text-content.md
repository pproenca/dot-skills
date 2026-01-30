---
title: Use toHaveTextContent() for Text Assertions
impact: MEDIUM
impactDescription: prevents whitespace-related false failures
tags: assert, toHaveTextContent, text, matchers
---

## Use toHaveTextContent() for Text Assertions

Use `toHaveTextContent()` instead of accessing `textContent` directly. It handles whitespace normalization and provides clear errors.

**Incorrect (direct property access):**

```tsx
render(<Badge>  Premium User  </Badge>)

const badge = screen.getByRole('status')
expect(badge.textContent).toBe('Premium User')
// Fails due to whitespace differences
```

**Correct (jest-dom matcher):**

```tsx
render(<Badge>  Premium User  </Badge>)

const badge = screen.getByRole('status')
expect(badge).toHaveTextContent('Premium User')
// Normalizes whitespace automatically
```

**Supports partial matching and regex:**

```tsx
// Partial match
expect(badge).toHaveTextContent('Premium')

// Regex match
expect(badge).toHaveTextContent(/premium/i)

// Exact match with option
expect(badge).toHaveTextContent('Premium User', { exact: true })
```

**For asserting empty text:**

```tsx
expect(emptyElement).toHaveTextContent('')
// or
expect(emptyElement).toBeEmptyDOMElement()
```

Reference: [jest-dom - toHaveTextContent](https://github.com/testing-library/jest-dom#tohavetextcontent)
