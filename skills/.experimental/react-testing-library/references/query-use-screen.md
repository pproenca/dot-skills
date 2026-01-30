---
title: Use screen for Queries
impact: CRITICAL
impactDescription: eliminates destructure maintenance overhead
tags: query, screen, render, best-practice
---

## Use screen for Queries

Import and use `screen` instead of destructuring queries from `render()`. This eliminates the need to update destructuring when query needs change.

**Incorrect (requires destructure maintenance):**

```tsx
const { getByRole, getByText, queryByRole } = render(<UserProfile />)

const heading = getByRole('heading')
const name = getByText('John Doe')
const badge = queryByRole('img')
// Must update destructure when adding new queries
```

**Correct (no destructure needed):**

```tsx
render(<UserProfile />)

const heading = screen.getByRole('heading')
const name = screen.getByText('John Doe')
const badge = screen.queryByRole('img')
// Simply use screen.* for any query
```

**Benefits:**
- Less boilerplate
- Easier to add new queries
- `screen.debug()` available automatically
- Consistent pattern across all tests

Reference: [Common Mistakes - Not Using screen](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#not-using-screen)
