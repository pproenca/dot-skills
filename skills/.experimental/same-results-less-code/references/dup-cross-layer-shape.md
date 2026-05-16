---
title: Collapse Identical DTOs, DB Rows, and Domain Objects
impact: HIGH
impactDescription: eliminates a layer of pass-through mappers and the entity-x3 type explosion
tags: dup, layers, dto, mapping
---

## Collapse Identical DTOs, DB Rows, and Domain Objects

The "clean architecture" instinct produces three types per entity: a database row type, a domain type, and a DTO for the API — plus the mappers between them. When the three types are *the same shape with the same field names and the same semantics*, the layers are decorative. Each new field requires editing three types and two mappers, and tests exist mainly to verify the mappers don't drop fields. Either keep three types because the shapes genuinely differ, or use one type and accept that the layers are conceptual, not physical.

**Incorrect (three identical types and two identity mappers per layer):**

```typescript
// db/types.ts
export type UserRow = { id: string; email: string; name: string; createdAt: Date };

// domain/types.ts
export type User = { id: string; email: string; name: string; createdAt: Date };

// api/types.ts
export type UserDto = { id: string; email: string; name: string; createdAt: Date };

// db/mappers.ts
export const rowToUser = (r: UserRow): User =>
  ({ id: r.id, email: r.email, name: r.name, createdAt: r.createdAt });

// api/mappers.ts
export const userToDto = (u: User): UserDto =>
  ({ id: u.id, email: u.email, name: u.name, createdAt: u.createdAt });

// Adding a field → 5 places to edit. Tests verify identity functions. No information added.
```

**Correct (option A — collapse to one type when shapes are truly identical):**

```typescript
export type User = { id: string; email: string; name: string; createdAt: Date };
// Used by the DB driver, the domain logic, and the API.
// If a layer needs to add a field, it does — and the layered separation re-emerges naturally.
```

**Correct (option B — keep separate types only when they really differ):**

```typescript
export type UserRow = { id: string; email: string; name: string; created_at: string };
// DB uses snake_case + string timestamps because the driver returns them that way.

export type User = { id: string; email: string; name: string; createdAt: Date };
// Domain uses camelCase + Date.

export type UserDto = Omit<User, 'email'>;
// API hides email from external consumers.

// Mappers now have a real job: type-system-distinct names, format conversions, field hiding.
```

**Symptoms of decorative layers:**

- The "mapper" is `(x) => ({ ...x })` or assigns identically named fields.
- Adding a field to the DB requires PRs across three files just to surface it.
- "Domain type" has no methods, no invariants, no behaviour — it's just a struct.
- The DTO is the domain object minus zero fields and plus zero fields.

**When NOT to use this pattern:**

- The layers are different *today*, even if barely — e.g. the DB stores `email_normalized` and the domain uses `email`. Keep them separate; the separation has paid a cost.
- You expect divergence soon for a known reason (API versioning, schema migration in flight). Time-bound the duplication.
- The team's architectural standard requires the layering and the cost is accepted as documentation/discipline. Then the question becomes: what fields are different? Make those visible.

Reference: [A Philosophy of Software Design — Pass-Through Methods](https://web.stanford.edu/~ouster/cgi-bin/aposd.php) (John Ousterhout)
