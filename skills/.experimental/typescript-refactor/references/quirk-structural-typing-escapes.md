---
title: Guard Against Structural Typing Escape Hatches
impact: LOW-MEDIUM
impactDescription: prevents extra properties from leaking through assignments
tags: quirk, structural-typing, type-safety, defensive-coding
---

## Guard Against Structural Typing Escape Hatches

TypeScript's structural type system means any object with the right properties satisfies an interface — even if it has extra properties. This is by design, but it can cause data leaks when spreading or serializing objects that carry more than expected.

**Incorrect (extra properties leak through structural compatibility):**

```typescript
interface PublicProfile {
  name: string
  avatar: string
}

function toPublicProfile(user: User): PublicProfile {
  return user // Compiles — User has name and avatar (plus email, password, etc.)
}

const profile = toPublicProfile(currentUser)
JSON.stringify(profile) // Includes email, password — data leak!
```

**Correct (explicitly pick properties):**

```typescript
interface PublicProfile {
  name: string
  avatar: string
}

function toPublicProfile(user: User): PublicProfile {
  return {
    name: user.name,
    avatar: user.avatar,
  }
}

const profile = toPublicProfile(currentUser)
JSON.stringify(profile) // Only name and avatar — safe
```

**Note:** This is especially important at API boundaries, logging, and serialization points where extra properties become visible outside the type system.
