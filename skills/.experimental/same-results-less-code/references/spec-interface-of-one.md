---
title: Avoid Defining an Interface for a Single Implementation
impact: MEDIUM
impactDescription: eliminates one-implementer interfaces and the indirection layer they impose
tags: spec, interface, generality, yagni
---

## Avoid Defining an Interface for a Single Implementation

Interfaces (or abstract classes) earn their cost when at least two implementations exist or are *imminent*. An interface with one implementer adds an indirection — every reader must navigate from interface to impl to find the actual code — for no payoff. The reason it's so common is a half-remembered "code to interfaces, not implementations" maxim, applied without the precondition: *interfaces in service of polymorphism*. If there's no polymorphism, there's no interface.

**Incorrect (an interface with exactly one implementer):**

```typescript
// users/UserService.ts
export interface UserService {
  findById(id: string): Promise<User | null>;
  create(input: CreateUserInput): Promise<User>;
  update(id: string, input: UpdateUserInput): Promise<User>;
  delete(id: string): Promise<void>;
}

// users/PostgresUserService.ts
export class PostgresUserService implements UserService {
  constructor(private readonly db: Database) {}
  async findById(id: string)  { return this.db.users.findUnique({ where: { id } }); }
  async create(input)         { return this.db.users.create({ data: input }); }
  async update(id, input)     { return this.db.users.update({ where: { id }, data: input }); }
  async delete(id)            { await this.db.users.delete({ where: { id } }); }
}

// Used at call sites as `UserService`. There is no `InMemoryUserService`, no `MockUserService`,
// no `MongoUserService`. The interface adds a file, a layer, and nothing else.
```

**Correct (just the class, exported directly):**

```typescript
// users/UserService.ts
export class UserService {
  constructor(private readonly db: Database) {}
  async findById(id: string)  { return this.db.users.findUnique({ where: { id } }); }
  async create(input: CreateUserInput) { return this.db.users.create({ data: input }); }
  async update(id: string, input: UpdateUserInput) { return this.db.users.update({ where: { id }, data: input }); }
  async delete(id: string)    { await this.db.users.delete({ where: { id } }); }
}
// The class's public methods ARE the interface. Tests can mock the class directly,
// or use dependency injection at the call site.
// If a second implementer appears, extract the interface THEN. Refactor is cheap.
```

**The "but I need to mock it for tests" objection:**

Most test frameworks can mock concrete classes — `vi.mock`, `jest.mock`, manual stubs. You don't need an interface to make a class mockable. If your DI container insists on an interface, that's the DI container's problem, not the design's.

**Symptoms of one-implementer interfaces:**

- An interface and one class with `implements`, both in the same module, both exported.
- The class name is `XxxImpl` or `DefaultXxx` — a strong signal the interface is anticipatory.
- Tests "use the interface" but actually instantiate the concrete class.
- The interface's methods are identical to the class's public methods (no abstraction in the interface itself).

**When NOT to use this pattern:**

- A second implementation genuinely exists or is on the near roadmap (a test fake counts as an implementation only if it's a fundamentally different one, not a `vi.fn()` wrapper).
- You're at an architectural boundary where the *promise* of multiple implementations is part of the contract — e.g. a public library exposing a `Storage` interface for users to implement. There, the interface is the surface.
- The interface lets you write `accepts: UserService` in a function signature that needs to be open to extension by a client — but that's a real polymorphism need.

Reference: [YAGNI — You Aren't Gonna Need It](https://martinfowler.com/bliki/Yagni.html) (Martin Fowler)
