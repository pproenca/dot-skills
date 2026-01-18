---
title: Always Include Default Case in Switch
impact: MEDIUM
impactDescription: prevents silent failures on unexpected values
tags: control, switch, default, exhaustive
---

## Always Include Default Case in Switch

All switch statements must include a `default` case, even if it's empty. All cases must terminate with `break`, `return`, or throw.

**Incorrect (missing default or fall-through):**

```typescript
function getStatusText(status: number): string {
  switch (status) {
    case 200:
      return 'OK'
    case 404:
      return 'Not Found'
    // Missing default - silent failure on unknown status
  }
}

switch (action) {
  case 'start':
    initialize()
    // Missing break - falls through!
  case 'stop':
    cleanup()
    break
}
```

**Correct (with default and explicit termination):**

```typescript
function getStatusText(status: number): string {
  switch (status) {
    case 200:
      return 'OK'
    case 404:
      return 'Not Found'
    case 500:
      return 'Server Error'
    default:
      return 'Unknown'
  }
}

// Empty default with comment explaining why
switch (knownStatus) {
  case Status.Active:
    activate()
    break
  case Status.Inactive:
    deactivate()
    break
  default:
    // All cases handled, default unreachable
    break
}
```

**Empty case fall-through is allowed:**

```typescript
switch (char) {
  case 'a':
  case 'e':
  case 'i':
  case 'o':
  case 'u':
    return true  // All vowels
  default:
    return false
}
```

Reference: [Google TypeScript Style Guide - Switch statements](https://google.github.io/styleguide/tsguide.html#switch-statements)
