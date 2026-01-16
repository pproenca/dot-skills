---
title: Rule Title Here
impact: MEDIUM
impactDescription: Quantified impact (e.g., "2-10× improvement", "200ms savings")
tags: prefix, technique, related-concept
---

## Rule Title Here

Brief explanation of WHY this rule matters for performance (1-3 sentences).

**Incorrect (description of the problem):**

```typescript
// Bad code example with realistic variable names
const user = await fetchUser()
const posts = await fetchPosts()  // Sequential - adds full network latency
```

**Correct (description of the solution):**

```typescript
// Good code example - minimal diff from incorrect
const [user, posts] = await Promise.all([
  fetchUser(),
  fetchPosts()
])
```

Reference: [Next.js Documentation](https://nextjs.org/docs)
