---
title: Prevent Type Widening with let Declarations
impact: LOW-MEDIUM
impactDescription: preserves literal types that would otherwise widen to string or number
tags: quirk, type-widening, let, const, literals
---

## Prevent Type Widening with let Declarations

TypeScript widens literal types for `let` variables because they can be reassigned. A `let status = "active"` becomes `string`, not `"active"`. Use `const`, explicit annotations, or `as const` to preserve literal types when they matter.

**Incorrect (let widens literal to base type):**

```typescript
let status = "active"
// Type: string — widened from "active"

function setStatus(s: "active" | "inactive") { /* ... */ }
setStatus(status) // Error: string not assignable to "active" | "inactive"
```

**Correct (preserve literal type):**

```typescript
// Option 1: const (when no reassignment needed)
const status = "active"
// Type: "active"

// Option 2: explicit annotation (when reassignment needed)
let status: "active" | "inactive" = "active"
// Type: "active" | "inactive"

// Option 3: as const (for complex expressions)
let config = { status: "active" as const }
// config.status type: "active"

function setStatus(s: "active" | "inactive") { /* ... */ }
setStatus(status) // OK with all three options
```
