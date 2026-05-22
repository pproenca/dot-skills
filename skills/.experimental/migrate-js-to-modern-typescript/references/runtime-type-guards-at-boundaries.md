---
title: Write Type Guards for Untyped Library Returns
impact: MEDIUM
impactDescription: prevents any from untyped libraries spreading
tags: runtime, type-guards, libraries, narrowing
---

## Write Type Guards for Untyped Library Returns

An untyped third-party function returns `any`, which silently poisons every value derived from it — the `any` flows outward with no error until something crashes. A user-defined type guard (`value is T`) verifies the shape at the single call site and narrows it, containing the `any` there instead of letting it leak through the program.

**Incorrect (untyped return spreads any downstream):**

```typescript
// legacyParser.parse returns any; token and its fields are unchecked
// everywhere they travel after this line.
const token = legacyParser.parse(header)
return token.claims.sub // unchecked all the way down
```

**Correct (a type guard contains the any at the boundary):**

```typescript
interface AuthToken {
  claims: { sub: string; exp: number }
}

function isAuthToken(value: unknown): value is AuthToken {
  return (
    typeof value === "object" &&
    value !== null &&
    "claims" in value &&
    typeof (value as AuthToken).claims?.sub === "string"
  )
}

const parsed: unknown = legacyParser.parse(header)
if (!isAuthToken(parsed)) throw new Error("Invalid token")
return parsed.claims.sub // narrowed to AuthToken, checked
```

Reference: [TypeScript Handbook: Type Predicates](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates)
