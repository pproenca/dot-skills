---
title: Use Exhaustive Checks for Typed Error Variants
impact: MEDIUM
impactDescription: prevents silent fallthrough when error variants expand
tags: error, exhaustive-checks, discriminated-unions, never
---

## Use Exhaustive Checks for Typed Error Variants

Model domain errors as a discriminated union and use exhaustive switch statements to handle each variant. When a new error type is added, the compiler flags every unhandled location.

**Incorrect (generic error, handler guesses):**

```typescript
function handleError(error: Error) {
  if (error.message.includes("not found")) {
    showNotFound()
  } else if (error.message.includes("unauthorized")) {
    redirectToLogin()
  } else {
    showGenericError() // New error types silently fall here
  }
}
```

**Correct (discriminated error union, exhaustive):**

```typescript
type AppError =
  | { type: "not_found"; resourceId: string }
  | { type: "unauthorized"; requiredRole: string }
  | { type: "validation"; fields: string[] }

function assertNever(value: never): never {
  throw new Error(`Unhandled error type: ${JSON.stringify(value)}`)
}

function handleError(error: AppError) {
  switch (error.type) {
    case "not_found":
      showNotFound(error.resourceId)
      break
    case "unauthorized":
      redirectToLogin(error.requiredRole)
      break
    case "validation":
      highlightFields(error.fields)
      break
    default:
      assertNever(error) // Compile error if new type added but not handled
  }
}
```
