---
title: Use within() to Scope Queries
impact: HIGH
impactDescription: isolates queries to specific containers, prevents false matches
tags: query, within, scope, container
---

## Use within() to Scope Queries

When testing components with repeated structures, use `within()` to scope queries to a specific container. This prevents matching elements from other parts of the DOM.

**Incorrect (queries entire document):**

```tsx
render(
  <div>
    <article data-testid="post-1">
      <h2>First Post</h2>
      <button>Delete</button>
    </article>
    <article data-testid="post-2">
      <h2>Second Post</h2>
      <button>Delete</button>
    </article>
  </div>
)

const deleteButton = screen.getByRole('button', { name: /delete/i })
// Error: Found multiple elements with role "button"
```

**Correct (scoped to specific container):**

```tsx
render(
  <div>
    <article data-testid="post-1">
      <h2>First Post</h2>
      <button>Delete</button>
    </article>
    <article data-testid="post-2">
      <h2>Second Post</h2>
      <button>Delete</button>
    </article>
  </div>
)

const firstPost = screen.getByRole('article', { name: /first post/i })
const deleteButton = within(firstPost).getByRole('button', { name: /delete/i })
// Finds only the delete button within first post
```

Reference: [Testing Library - within](https://testing-library.com/docs/dom-testing-library/api-within)
