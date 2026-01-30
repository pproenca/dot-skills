---
title: Avoid getByTestId as Primary Query
impact: CRITICAL
impactDescription: prevents testing implementation details instead of behavior
tags: query, testid, accessibility, anti-pattern
---

## Avoid getByTestId as Primary Query

`getByTestId` should be a last resort. Users cannot see or hear test IDs, so tests using them don't verify the actual user experience.

**Incorrect (invisible to users):**

```tsx
render(
  <form>
    <label htmlFor="email">Email</label>
    <input id="email" data-testid="email-input" />
  </form>
)

const input = screen.getByTestId('email-input')
// User cannot see data-testid attribute
```

**Correct (matches user experience):**

```tsx
render(
  <form>
    <label htmlFor="email">Email</label>
    <input id="email" data-testid="email-input" />
  </form>
)

const input = screen.getByLabelText('Email')
// User navigates by label text
```

**When testid IS acceptable:**
- Dynamic content where text changes frequently
- Elements without semantic meaning (decorative containers)
- As a fallback when no other query works

Reference: [Testing Library Queries - ByTestId](https://testing-library.com/docs/queries/bytestid)
