---
title: Drop the Generic Parameter When Only One Concrete Type Uses It
impact: MEDIUM
impactDescription: eliminates one-type generic indirection; reduces 5-10 lines of type plumbing
tags: spec, generics, types, yagni
---

## Drop the Generic Parameter When Only One Concrete Type Uses It

Generics earn their cost when at least two concrete types share the structure they describe. A function or class with one `<T>` that is always instantiated with the same concrete type adds noise: callers must look at type parameters they don't need, type inference may fail at the boundary, and the generic prevents the function from being specific where specificity helps (e.g. allowing fields the generic can't express). Specialise to the concrete type until a second use shows up.

**Incorrect (a generic with exactly one concrete instantiation):**

```typescript
class Repository<T extends { id: string }> {
  private items: Map<string, T> = new Map();

  save(item: T): void           { this.items.set(item.id, item); }
  findById(id: string): T | null { return this.items.get(id) ?? null; }
  findAll(): T[]                 { return [...this.items.values()]; }
}

// The only place it's used:
const userRepo = new Repository<User>();
// Nothing else instantiates `Repository`. The generic `T` is decoration.
// It also prevents the repository from having User-specific methods like `findByEmail`.
```

**Correct (concrete; gains user-specific operations as a bonus):**

```typescript
class UserRepository {
  private users: Map<string, User> = new Map();

  save(user: User): void          { this.users.set(user.id, user); }
  findById(id: string): User | null { return this.users.get(id) ?? null; }
  findByEmail(email: string): User | null {
    return [...this.users.values()].find(u => u.email === email) ?? null;
  }
  findAll(): User[]               { return [...this.users.values()]; }
}
// Smaller signature for the same operations.
// Plus a `findByEmail` that the generic version couldn't express without making T more constrained.
// If a second repository appears later (Order, Product), THEN consider whether to extract a shared
// generic — or just write the second concrete class.
```

**The "duplicated code" objection:**

Two repositories with identical operations *will* share lines if extracted to a generic. But: (a) they almost always need specialised methods that the generic can't carry; (b) two copies of five methods is rarely a problem worth the abstraction; (c) extract the generic *later* when the duplication has actually appeared three times. Rule of three applies.

**Symptoms:**

- A single `Repository<User>` / `Cache<Order>` / `Mapper<Foo, Bar>` in the codebase with no other instantiation.
- A type parameter constrained tightly enough (`<T extends { id: string }>`) that it's already half-specialised.
- A class whose generic parameter is threaded through every method but never used in a way only `<T>` could express (just `T -> T`).

**When NOT to use this pattern:**

- The generic is part of a *library API* exposed to consumers who'll instantiate it with their own types — the parameter is the contract.
- Two or more concrete instantiations exist today. The generic is real polymorphism.
- The class implements a structural pattern (`Result<T, E>`, `Option<T>`, `Observable<T>`) where the type parameter is the whole point.

Reference: [TypeScript Handbook — Generics: "Type Parameters in Generic Constraints"](https://www.typescriptlang.org/docs/handbook/2/generics.html)
