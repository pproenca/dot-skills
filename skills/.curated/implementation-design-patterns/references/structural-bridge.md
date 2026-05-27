---
title: Use Bridge to Split Abstraction from Implementation
impact: MEDIUM
impactDescription: prevents exponential subclass explosion when a class varies along two or more independent dimensions, allows abstraction and implementation hierarchies to evolve separately, enables runtime swapping of implementations
tags: structural, bridge, composition-over-inheritance, orthogonal-dimensions
---

## Use Bridge to Split Abstraction from Implementation

**Pattern intent:** decouple an abstraction from its implementation so both can vary independently. Replace inheritance across two orthogonal dimensions with a reference from the abstraction to the implementation.

### Shapes to recognize

- Subclass count grows as the product of two dimensions: `RedCircle`, `BlueCircle`, `GreenCircle`, `RedSquare`, `BlueSquare`, `GreenSquare`...
- A "shape × renderer" or "device × OS" or "remote × device" matrix where each cell needs a new subclass
- A class needs to switch implementations at runtime
- A monolithic class whose responsibilities split cleanly across two orthogonal axes

### Problem

When a class hierarchy extends along two or more independent dimensions, subclass count grows as their product. Adding one variation along either dimension forces creating many new subclasses.

### Solution

Extract one dimension into a separate hierarchy (the *implementation*). The original hierarchy (the *abstraction*) references an implementation object and delegates the variable behavior to it. Each axis can grow independently.

**Incorrect (subclass explosion across two axes):**

```typescript
// Two axes: shape × renderer. Each combination is a class.
class RedCircle    { draw() { /* red + circle */ } }
class BlueCircle   { draw() { /* blue + circle */ } }
class GreenCircle  { draw() { /* green + circle */ } }
class RedSquare    { draw() { /* red + square */ } }
class BlueSquare   { draw() { /* blue + square */ } }
class GreenSquare  { draw() { /* green + square */ } }
// Adding a Triangle adds 3 classes; adding "Yellow" adds 2 more; explosion is multiplicative.
```

**Correct (abstraction holds an implementation reference):**

```typescript
/**
 * The Abstraction defines the interface for the "control" part of the two class
 * hierarchies. It maintains a reference to an object of the Implementation
 * hierarchy and delegates all of the real work to this object.
 */
class Abstraction {
    protected implementation: Implementation;

    constructor(implementation: Implementation) {
        this.implementation = implementation;
    }

    public operation(): string {
        const result = this.implementation.operationImplementation();
        return `Abstraction: Base operation with:\n${result}`;
    }
}

/**
 * You can extend the Abstraction without changing the Implementation classes.
 */
class ExtendedAbstraction extends Abstraction {
    public operation(): string {
        const result = this.implementation.operationImplementation();
        return `ExtendedAbstraction: Extended operation with:\n${result}`;
    }
}

/**
 * The Implementation defines the interface for all implementation classes. It
 * doesn't have to match the Abstraction's interface. In fact, the two
 * interfaces can be entirely different. Typically the Implementation interface
 * provides only primitive operations, while the Abstraction defines higher-
 * level operations based on those primitives.
 */
interface Implementation {
    operationImplementation(): string;
}

/**
 * Each Concrete Implementation corresponds to a specific platform and
 * implements the Implementation interface using that platform's API.
 */
class ConcreteImplementationA implements Implementation {
    public operationImplementation(): string {
        return 'ConcreteImplementationA: Here\'s the result on the platform A.';
    }
}

class ConcreteImplementationB implements Implementation {
    public operationImplementation(): string {
        return 'ConcreteImplementationB: Here\'s the result on the platform B.';
    }
}

/**
 * Except for the initialization phase, where an Abstraction object gets linked
 * with a specific Implementation object, the client code should only depend on
 * the Abstraction class. This way the client code can support any abstraction-
 * implementation combination.
 */
function clientCode(abstraction: Abstraction) {
    console.log(abstraction.operation());
}

let implementation = new ConcreteImplementationA();
let abstraction = new Abstraction(implementation);
clientCode(abstraction);

console.log('');

implementation = new ConcreteImplementationB();
abstraction = new ExtendedAbstraction(implementation);
clientCode(abstraction);
```

**Output:**

```text
Abstraction: Base operation with:
ConcreteImplementationA: Here's the result on the platform A.

ExtendedAbstraction: Extended operation with:
ConcreteImplementationB: Here's the result on the platform B.
```

### When to use

- A monolithic class has multiple functional variants and you want to divide responsibilities
- A class must extend across two or more orthogonal (independent) dimensions
- You need to switch implementations at runtime (Adapter is retrofitted; Bridge is designed up-front)

### When NOT to use

- The two axes are *not* truly independent — Bridge adds indirection that buys nothing
- The class has only a handful of variants and the matrix is small
- A highly cohesive class would lose clarity if forcibly split

### Implementation Steps

1. Identify orthogonal dimensions in your classes
2. Define operations the client needs in the base abstraction class
3. Determine platform operations and declare them in the implementation interface
4. Create concrete implementation classes
5. Add a field for the implementation in abstraction; pass via constructor
6. Create refined abstractions for high-level logic variants
7. Client code passes an implementation object to the abstraction at construction time

### Pros

- Create platform-independent classes and applications
- Client code works through high-level abstractions; platform details stay hidden
- Open/Closed Principle: introduce new abstractions and implementations independently
- Single Responsibility Principle: each hierarchy focuses on one axis

### Cons

- Adds complexity for highly cohesive classes that would be clearer monolithic

### Related Patterns

- **Adapter** — Adapter is retrofitted; Bridge is designed up-front
- **State / Strategy** — share Bridge's composition-based structure but solve different problems
- **Abstract Factory** — pairs well with Bridge to create matching abstraction/implementation combinations
- **Builder** — director acts as abstraction, builders as implementations

Reference: [refactoring.guru/design-patterns/bridge](https://refactoring.guru/design-patterns/bridge)
