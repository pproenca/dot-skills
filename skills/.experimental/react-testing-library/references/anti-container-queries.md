---
title: Avoid Using container for Queries
impact: CRITICAL
impactDescription: prevents brittle tests tied to DOM structure
tags: anti, container, querySelector, implementation-details
---

## Avoid Using container for Queries

Using `container.querySelector` bypasses Testing Library's user-centric queries. Tests become brittle and tied to specific DOM structure.

**Incorrect (DOM structure dependency):**

```tsx
const { container } = render(<UserCard user={user} />)

const avatar = container.querySelector('.user-card__avatar img')
const name = container.querySelector('[data-testid="name"]')
// Tied to CSS classes and DOM structure
```

**Correct (user-centric queries):**

```tsx
render(<UserCard user={user} />)

const avatar = screen.getByRole('img', { name: /avatar/i })
const name = screen.getByRole('heading', { name: /john doe/i })
// Tests what users actually see
```

**When container access IS acceptable:**
- Snapshot testing with `asFragment()`
- Testing CSS-in-JS styles (rarely needed)
- Integration with non-React DOM libraries

```tsx
// Snapshot testing
const { asFragment } = render(<Icon name="check" />)
expect(asFragment()).toMatchSnapshot()
```

Reference: [Common Mistakes - Using container to Query](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#using-container-to-query-for-elements)
