---
title: Constrain Generics Minimally
impact: HIGH
impactDescription: enables wider reuse without sacrificing type safety
tags: generic, constraints, extends, reusability
---

## Constrain Generics Minimally

Over-constraining generics couples them to specific implementations and limits reuse. Constrain to the minimal interface needed — use the properties you actually access, not the full type.

**Incorrect (over-constrained to specific type):**

```typescript
function getDisplayName<T extends User>(entity: T): string {
  return entity.name
}

// Cannot use with Organization, Team, or any other named entity
getDisplayName(organization) // Error: Organization not assignable to User
```

**Correct (constrained to minimal interface):**

```typescript
function getDisplayName<T extends { name: string }>(entity: T): string {
  return entity.name
}

getDisplayName(user)          // OK
getDisplayName(organization)  // OK
getDisplayName(team)          // OK — any object with .name works
```

**Note:** This follows the Interface Segregation Principle — depend on the smallest interface that satisfies your needs.
