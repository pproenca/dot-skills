---
title: Use Prototype to Clone Objects Without Coupling to Concrete Classes
impact: MEDIUM
impactDescription: enables copying complex pre-configured objects through a common `clone()` interface, preserves access to private fields that external copy code cannot reach, removes the need for parallel "copy constructor" subclasses
tags: creational, prototype, cloning, encapsulation, deep-copy
---

## Use Prototype to Clone Objects Without Coupling to Concrete Classes

**Pattern intent:** copy existing objects without making code depend on their concrete classes. Each class implements a `clone()` method that produces an equivalent instance, including private fields the caller could never reach.

### Shapes to recognize

- Manual "copy constructor" code that reads every field of an object — and breaks when private fields exist
- A registry of pre-configured "template" objects that callers want to duplicate, not subclass
- Need to copy an object received through an interface — you don't know the concrete class
- Avoiding deep recursive constructor chains by cloning a configured instance

### Problem

Copying an object from outside requires reading its fields, which may be private or unknown. Code that depends on the object's concrete class to copy it becomes tightly coupled and breaks when only the interface is known.

### Solution

Give each cloneable class a `clone()` method that returns an independent copy. The object copies its own state, so private fields are preserved. Optionally maintain a registry of frequently-used prototypes that clients can clone by name instead of constructing from scratch.

**Incorrect (external copy code can't reach private fields):**

```typescript
class UserProfile {
  public name: string;
  private internalToken: string; // external copy code cannot see this

  constructor(name: string, internalToken: string) {
    this.name = name;
    this.internalToken = internalToken;
  }
}

function copyProfile(profile: UserProfile): UserProfile {
  // We can only copy what's public — the internal token is silently lost.
  return new UserProfile(profile.name, '');
}
```

**Correct (object clones itself):**

```typescript
/**
 * The example class that has cloning ability. We'll see how the values of field
 * with different types will be cloned.
 */
class Prototype {
    public primitive: any;
    public component: object;
    public circularReference: ComponentWithBackReference;

    public clone(): this {
        const clone = Object.create(this);

        clone.component = Object.create(this.component);

        // Cloning an object that has a nested object with backreference
        // requires special treatment. After the cloning is completed, the
        // nested object should point to the cloned object, instead of the
        // original object. Spread operator can be handy for this case.
        clone.circularReference = new ComponentWithBackReference(clone);

        return clone;
    }
}

class ComponentWithBackReference {
    public prototype;

    constructor(prototype: Prototype) {
        this.prototype = prototype;
    }
}

function clientCode() {
    const p1 = new Prototype();
    p1.primitive = 245;
    p1.component = new Date();
    p1.circularReference = new ComponentWithBackReference(p1);

    const p2 = p1.clone();
    if (p1.primitive === p2.primitive) {
        console.log('Primitive field values have been carried over to a clone. Yay!');
    } else {
        console.log('Primitive field values have not been copied. Booo!');
    }
    if (p1.component === p2.component) {
        console.log('Simple component has not been cloned. Booo!');
    } else {
        console.log('Simple component has been cloned. Yay!');
    }

    if (p1.circularReference === p2.circularReference) {
        console.log('Component with back reference has not been cloned. Booo!');
    } else {
        console.log('Component with back reference has been cloned. Yay!');
    }

    if (p1.circularReference.prototype === p2.circularReference.prototype) {
        console.log('Component with back reference is linked to original object. Booo!');
    } else {
        console.log('Component with back reference is linked to the clone. Yay!');
    }
}

clientCode();
```

**Output:**

```text
Primitive field values have been carried over to a clone. Yay!
Simple component has been cloned. Yay!
Component with back reference has been cloned. Yay!
Component with back reference is linked to the clone. Yay!
```

### When to use

- Your code shouldn't depend on the concrete classes of objects you copy
- You receive objects through an interface and need to duplicate them
- You have many subclasses that differ only in initialization — replace them with pre-configured prototypes
- A central registry of configured prototypes can replace subclassing for "preset" variants

### When NOT to use

- The object is a value (primitive, plain data record) — direct copy via spread or `structuredClone` is simpler
- The object holds external resources (sockets, file handles, transactions) — cloning leaks them
- Circular references make safe deep-copy difficult and you don't need to clone — refactor the graph instead

### Implementation Steps

1. Declare a prototype interface with a `clone()` method
2. Define an alternative constructor accepting an instance of the same class, copying every field
3. Override `clone()` explicitly in each class so it always returns the right concrete type
4. Optionally create a centralized prototype registry for frequently-used presets
5. Replace direct constructor calls with registry lookups when appropriate

### Pros

- Clone objects without coupling to concrete classes
- Eliminate repeated initialization code by favoring pre-built prototypes
- Produce complex objects more conveniently than via inheritance
- Alternative to inheritance for configuration presets

### Cons

- Cloning complex objects with circular references requires careful handling
- Easy to mistake a shallow copy for a deep copy

### Related Patterns

- **Factory Method** — Prototype is an alternative when inheritance is undesirable
- **Abstract Factory** — concrete factories may store and clone prototypes instead of using `new`
- **Memento** — Prototype can be a simpler alternative for straightforward objects with mostly public state
- **Composite/Decorator** — benefit from Prototype when cloning structures instead of reconstructing
- **Command** — saving copies of commands for history uses Prototype

Reference: [refactoring.guru/design-patterns/prototype](https://refactoring.guru/design-patterns/prototype)
