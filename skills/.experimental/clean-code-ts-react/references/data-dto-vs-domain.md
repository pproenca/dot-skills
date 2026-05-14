---
title: Separate DTOs from Domain Types
impact: MEDIUM-HIGH
impactDescription: localizes API changes to a translation layer
tags: data, dto, domain, boundaries
---

## Separate DTOs from Domain Types

The shape your API returns rarely matches the shape your domain wants — snake_case keys, string-encoded dates, nullable fields that your UI treats as defaulted. Using the API shape directly couples every component to the wire format; a translation step at the boundary lets the domain stay clean and the change surface stay small when the API moves.

**Incorrect (wire format leaks into every consumer):**

```ts
// Every component now knows about user_id, created_at strings, and nullable bios.
// API renames user_id -> id? Every consumer breaks.
type User = {
  user_id: string;
  created_at: string;
  profile_data: { bio: string | null };
};

function UserHeader({ user }: { user: User }) {
  const joined = new Date(user.created_at).toLocaleDateString();
  return <h1>{user.profile_data.bio ?? 'No bio'} — joined {joined}</h1>;
}
```

**Correct (translate at the edge, keep the domain clean):**

```ts
// One translator absorbs API quirks; consumers see idiomatic domain types.
type UserDTO = {
  user_id: string;
  created_at: string;
  profile_data: { bio: string | null };
};

type User = {
  id: string;
  createdAt: Date;
  bio: string;
};

const toUser = (dto: UserDTO): User => ({
  id: dto.user_id,
  createdAt: new Date(dto.created_at),
  bio: dto.profile_data.bio ?? 'No bio',
});

function UserHeader({ user }: { user: User }) {
  return <h1>{user.bio} — joined {user.createdAt.toLocaleDateString()}</h1>;
}
```

**When NOT to apply this pattern:**
- API and domain genuinely have the same shape — internal tools, admin UIs that are thin wrappers over CRUD endpoints.
- Generated SDK clients (OpenAPI, tRPC, GraphQL codegen) — the generated types already provide a stable boundary; adding another translation layer duplicates effort.
- Tiny apps where the cost of maintaining two parallel type hierarchies exceeds the cost of API coupling.

**Why this matters:** A translation boundary turns "change ripples through the codebase" into "change touches one mapper" — the same locality-of-change principle behind wrapping third-party hooks.

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Anti-Corruption Layer — Domain-Driven Design](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer)
