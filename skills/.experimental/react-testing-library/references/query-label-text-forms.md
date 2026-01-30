---
title: Use getByLabelText for Form Fields
impact: CRITICAL
impactDescription: catches 100% of broken label-input associations
tags: query, getByLabelText, forms, accessibility
---

## Use getByLabelText for Form Fields

For form inputs, `getByLabelText` is preferred because it matches how users (including those using screen readers) interact with forms via labels.

**Incorrect (tests placeholder, not label):**

```tsx
render(
  <form>
    <label htmlFor="username">Username</label>
    <input id="username" placeholder="Enter username" />
  </form>
)

const input = screen.getByPlaceholderText('Enter username')
// Placeholder is not a substitute for a label
```

**Correct (tests actual label association):**

```tsx
render(
  <form>
    <label htmlFor="username">Username</label>
    <input id="username" placeholder="Enter username" />
  </form>
)

const input = screen.getByLabelText('Username')
// Verifies label-input association works
```

**Note:** This also works with `aria-label` and `aria-labelledby`:

```tsx
<input aria-label="Search" />
const input = screen.getByLabelText('Search')
```

Reference: [Testing Library Queries - ByLabelText](https://testing-library.com/docs/queries/bylabeltext)
