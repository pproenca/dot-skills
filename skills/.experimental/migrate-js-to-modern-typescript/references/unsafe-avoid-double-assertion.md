---
title: Avoid Double Assertions That Force Unrelated Types
impact: MEDIUM-HIGH
impactDescription: prevents hidden type mismatches
tags: unsafe, double-assertion, casts
---

## Avoid Double Assertions That Force Unrelated Types

`value as unknown as Target` defeats every safety check the compiler offers and is a reliable migration smell — it appears wherever someone forced a stubborn error to go away. It hides a genuine mismatch between the real value and the asserted type, which then surfaces as a runtime crash that the type checker swore could not happen.

**Incorrect (double assertion forces an incompatible type):**

```typescript
// session actually has { uid }, but this forces it to User and then reads
// fields that do not exist at runtime.
const user = session as unknown as User
sendWelcome(user.email) // user.email is undefined at runtime
```

**Correct (map the real shape to the target explicitly):**

```typescript
function toUser(session: Session): User {
  return {
    id: session.uid,
    email: lookupEmail(session.uid),
  }
}

const user = toUser(session)
sendWelcome(user.email)
```

Reference: [Effective TypeScript](https://effectivetypescript.com/)
