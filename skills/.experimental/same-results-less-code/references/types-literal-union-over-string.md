---
title: Narrow string Down to a Literal Union When the Set Is Closed
impact: LOW-MEDIUM
impactDescription: eliminates runtime string-comparison guards; enables compiler-checked exhaustiveness
tags: types, literal, union, stringly-typed
---

## Narrow string Down to a Literal Union When the Set Is Closed

A parameter typed `status: string` accepts any string — `"active"`, `"actve"`, `"ACTIVE"`, `"banana"`. So every function that handles status has to defensively check, fall through to a default, or trust the caller. When the set of valid values is fixed and small, model it as a literal union (`'active' | 'inactive' | 'banned'`). Now the compiler refuses bad values, exhaustive `switch`es catch missing cases, and the defensive code goes away.

**Incorrect (stringly-typed, defended everywhere):**

```typescript
function statusColor(status: string): string {
  switch (status) {
    case 'active':   return 'green';
    case 'inactive': return 'gray';
    case 'banned':   return 'red';
    default:         return 'black';                      // accepts 'actve' silently
  }
}

// Caller — no compile error:
statusColor('actve');
// Returns 'black'. The bug is never reported until a designer asks why some users are black.
```

**Correct (the type is the set):**

```typescript
type Status = 'active' | 'inactive' | 'banned';

function statusColor(status: Status): string {
  switch (status) {
    case 'active':   return 'green';
    case 'inactive': return 'gray';
    case 'banned':   return 'red';
  }
  // No default needed — the switch is exhaustive. TS will tell you if Status grows.
}

// Caller:
statusColor('actve');
// Compile error: Argument of type '"actve"' is not assignable to parameter of type 'Status'.
```

**Lifting from API/DB strings into the union at the boundary:**

```typescript
import { z } from 'zod';

const Status = z.enum(['active', 'inactive', 'banned']);
type Status = z.infer<typeof Status>;

// Parse once at the boundary:
const parseUser = (row: unknown): User => {
  const data = z.object({ id: z.string(), status: Status }).parse(row);
  return data;
};
// Inside the system, `status` is `Status`, not `string`. The "what if it's a typo" question
// disappears — the parse step already answered it.
```

**Symptoms:**

- A parameter or field typed `string` where the body is a switch over 3-5 known values.
- A `default` branch returning a sentinel because "unknown values shouldn't happen but might."
- Tests including a case for "an unknown status."
- Documentation that says "status must be one of: active, inactive, banned."

**When NOT to use this pattern:**

- The set is genuinely open — user-provided tags, free-form labels, dynamic categories. Keep `string`.
- The set is closed but huge (hundreds of country codes) — a literal union still works (`Country = 'US' | 'GB' | …`) but a runtime-validated string with a list constant may be more practical. Use `as const` arrays + a derived type if you also need iteration: `const COUNTRIES = ['US', 'GB', …] as const; type Country = typeof COUNTRIES[number];`.
- You're at the persistence boundary and the DB stores strings — that's fine; widen at the boundary, narrow back to the union via parsing.

Reference: [TypeScript Handbook — Literal Types](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#literal-types)
