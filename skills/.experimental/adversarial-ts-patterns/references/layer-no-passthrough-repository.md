---
title: No repository classes that delegate 1-to-1 to an already-abstract data client
tags: layer, repository, orm, enterprise
---

## No repository classes that delegate 1-to-1 to an already-abstract data client

The wrong default is wrapping Prisma, Drizzle, or a query client in a `UserRepository` class because "data access goes behind a repository". Fowler's Repository mediates between the domain and the data layer by translating persistence records into domain objects and encapsulating query construction; a wrapper whose every method is one delegate call does neither — the ORM already is the abstraction. The pass-through version adds a file, an injection point, and a naming scheme per entity, and gets stale the moment someone needs a query it forgot to mirror.

**Evidence of violation:** a class (or object of functions) named `*Repository`/`*Dao`/`*Store` where every method body is a single call to the wrapped client with the same arguments passed through — no domain-type mapping, no invariant enforcement, no query composition. The carve-out is a repository doing real mediation — mapping rows into domain types with behavior, enforcing invariants before writes, or assembling non-trivial queries; one pass-through method in an otherwise-working repository is not a violation, a repository of only pass-throughs is.

**Incorrect (every method mirrors the client 1-to-1):**

```ts
export class UserRepository {
  constructor(private readonly db: PrismaClient) {}
  findById(id: string)        { return this.db.user.findUnique({ where: { id } }) }
  findByEmail(email: string)  { return this.db.user.findUnique({ where: { email } }) }
  create(data: NewUser)       { return this.db.user.create({ data }) }
  delete(id: string)          { return this.db.user.delete({ where: { id } }) }
}
```

**Correct (call the client where you need it; extract functions when queries earn it):**

```ts
// Queries with real content earn a named function; the rest is just the client.
export function findActiveTeamMembers(db: PrismaClient, teamId: string) {
  return db.user.findMany({
    where: { teamId, deactivatedAt: null, invites: { none: { pending: true } } },
    orderBy: { lastSeenAt: "desc" },
  })
}
```

Reference: [Martin Fowler — Patterns of Enterprise Application Architecture, Repository](https://martinfowler.com/eaaCatalog/repository.html)
