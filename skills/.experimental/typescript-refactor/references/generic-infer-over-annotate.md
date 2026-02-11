---
title: Let TypeScript Infer Instead of Explicit Annotation
impact: HIGH
impactDescription: reduces verbosity while maintaining full type safety
tags: generic, inference, type-annotations, readability
---

## Let TypeScript Infer Instead of Explicit Annotation

TypeScript's inference engine handles most cases — explicit generic annotations are often unnecessary and add visual noise. Rely on inference from arguments and return types, and annotate only when inference fails or produces unwanted widening.

**Incorrect (redundant generic annotations):**

```typescript
const users = new Map<string, User>()
const names = users.values().map<string>((user: User) => user.name)
const sorted = names.sort((a: string, b: string) => a.localeCompare(b))

const result = await fetchUsers<User[]>() // Generic already matches return type
```

**Correct (let inference work):**

```typescript
const users = new Map<string, User>()
const names = [...users.values()].map(user => user.name)
const sorted = names.sort((a, b) => a.localeCompare(b))

const result = await fetchUsers() // Return type already typed in function signature
```

**When to annotate explicitly:**
- When inference produces a wider type than intended (use `as const` or `satisfies`)
- When the function signature doesn't constrain the return type
- When types span module boundaries and inference would be opaque
