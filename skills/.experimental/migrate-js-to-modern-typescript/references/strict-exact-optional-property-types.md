---
title: Enable exactOptionalPropertyTypes to Separate Missing from Undefined
impact: MEDIUM-HIGH
impactDescription: prevents absent-versus-undefined confusion
tags: strict, exactoptionalpropertytypes, optional
---

## Enable exactOptionalPropertyTypes to Separate Missing from Undefined

Without this flag, `{ nickname?: string }` also accepts `{ nickname: undefined }`, erasing the difference between an absent key and an explicit `undefined`. JavaScript code relies on that distinction for `in` checks, `Object.keys`, and JSON serialization, so conflating them lets a "clear this field" intent silently read as "leave it unset."

**Incorrect (explicit undefined silently allowed):**

```typescript
interface UserPatch {
  nickname?: string
}

function update(patch: UserPatch): void {
  // A caller passes { nickname: undefined } meaning "clear it", but code
  // using `"nickname" in patch` reads it as "set" — the two paths diverge.
  applyPatch(patch)
}
```

**Correct (flag forces intent to be explicit):**

```typescript
interface UserPatch {
  // With exactOptionalPropertyTypes, this cannot be set to undefined.
  nickname?: string
}

function update(patch: UserPatch): void {
  applyPatch(patch) // callers must omit the key or pass a real string
}

// To allow clearing a field, model it deliberately as string | null.
```

Reference: [tsconfig: exactOptionalPropertyTypes](https://www.typescriptlang.org/tsconfig/#exactOptionalPropertyTypes)
