---
title: Extend Interfaces Instead of Intersecting Types
impact: CRITICAL
impactDescription: 2-3× faster type-checking, detects property conflicts
tags: arch, interfaces, intersections, compiler-performance
---

## Extend Interfaces Instead of Intersecting Types

Intersection types recursively merge properties and can silently produce `never` on conflicts. Interfaces create a single flat object type, detect property conflicts at declaration, and are cached by the compiler for faster checking.

**Incorrect (intersection hides conflicts, slower):**

```typescript
type BaseEntity = {
  id: string
  createdAt: Date
}

type Timestamped = {
  createdAt: string // Conflict: Date vs string
  updatedAt: Date
}

type User = BaseEntity & Timestamped // createdAt becomes never — no error
```

**Correct (interface detects conflicts, faster):**

```typescript
interface BaseEntity {
  id: string
  createdAt: Date
}

interface Timestamped extends BaseEntity {
  updatedAt: Date
}

interface User extends Timestamped {
  email: string
}
// If createdAt types conflict, compiler reports error immediately
```

**Performance benefit:** The compiler caches interface types but must recursively flatten intersections on every use. In large codebases with hundreds of type references, this compounds into measurable build time increases.

**When NOT to use this pattern:**
- When you need union types (interfaces cannot represent unions)
- When composing types dynamically with mapped/conditional types

Reference: [TypeScript Performance Wiki - Preferring Interfaces Over Intersections](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-interfaces-over-intersections)
