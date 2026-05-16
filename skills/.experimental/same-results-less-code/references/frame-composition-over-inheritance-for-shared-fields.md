---
title: Compose Shared Fields Instead of Inheriting From a Base Class
impact: CRITICAL
impactDescription: eliminates rigid multi-level class hierarchies in favour of intersected types
tags: frame, inheritance, composition, oop
---

## Compose Shared Fields Instead of Inheriting From a Base Class

Inheritance is for **substitutability** — `Dog` is-a `Animal`, you can pass either where `Animal` is expected. When inheritance is used to "share fields and helper methods," you've taken a small data-sharing problem and bound your types into a rigid hierarchy. Every subclass must accept every base-class field and every base-class method, forever. Composition (an interface, a field of a shared type, a mixin function) does the same job without the lock-in.

**Incorrect (`BaseEntity` glued to every model so they can share `id`/`createdAt`):**

```typescript
abstract class BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
  protected log(message: string) { console.log(`[${this.id}] ${message}`); }
  abstract validate(): void;
}

class User extends BaseEntity {
  email: string;
  validate() { if (!this.email.includes('@')) throw new Error('bad email'); }
}

class Order extends BaseEntity {
  total: number;
  validate() { if (this.total < 0) throw new Error('negative'); }
}

// Three problems:
// 1. Order needs `updatedAt` because Base says so, even if Order is immutable.
// 2. `validate()` lives on Base but has nothing structural in common across types.
// 3. Adding a new mixin (say, `Versioned`) requires a new base or multiple-inheritance gymnastics.
```

**Correct (compose the shared shape; functions handle the shared verbs):**

```typescript
type Identified = { id: string; createdAt: Date };

type User  = Identified & { kind: 'user';  email: string };
type Order = Identified & { kind: 'order'; total: number };

const validateUser  = (u: User)  => { if (!u.email.includes('@')) throw new Error('bad email'); };
const validateOrder = (o: Order) => { if (o.total < 0)            throw new Error('negative'); };

const logFor = (e: Identified) => (msg: string) => console.log(`[${e.id}] ${msg}`);
// Each type carries exactly the fields it needs.
// `validate` is N independent functions, not one virtual hook.
// Adding `Versioned` is intersecting another type — no hierarchy to refactor.
```

**Symptoms of inheritance-for-sharing:**

- The base class has fields used by *every* subclass for *different* reasons.
- Subclasses override a base method with `super.foo()` plus a tweak (the "fragile base class" problem).
- The hierarchy is two levels deep "because we needed to share with siblings."
- The base class has both `abstract` methods and concrete helpers — the abstract part is the real polymorphism; the helpers are field-sharing wearing a hood.

**When NOT to use this pattern:**

- Inheritance models a genuine "is-a substitutable" relationship — `class CreditCardPayment extends Payment` where every `Payment` consumer treats them uniformly. Keep it.
- Framework requirements force a base class (`class extends React.Component`, `class extends NSObject`). The framework owns the hierarchy; you don't get a choice.

Reference: [Design Patterns — "Favor object composition over class inheritance"](https://en.wikipedia.org/wiki/Composition_over_inheritance) (Gang of Four)
