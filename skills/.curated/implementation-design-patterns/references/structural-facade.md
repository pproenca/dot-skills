---
title: Use Facade to Hide a Complex Subsystem Behind One Interface
impact: HIGH
impactDescription: replaces sprawling client code that orchestrates many subsystem objects with a single entry-point class, reduces coupling between application code and third-party library internals, eliminates duplicated initialization sequences across callers
tags: structural, facade, simplification, subsystem-isolation, single-entry-point
---

## Use Facade to Hide a Complex Subsystem Behind One Interface

**Pattern intent:** provide a unified, simplified interface to a complex subsystem. The facade exposes only the operations clients need and orchestrates the subsystem's objects internally.

### Shapes to recognize

- Client code that imports a dozen subsystem classes and orchestrates them in a fixed sequence (init, configure, run, teardown)
- A third-party library with a sprawling API where you actually use only 3-4 capabilities
- Initialization sequences duplicated across the codebase — each caller assembles the same scaffolding
- "Why is this one feature so complicated to use?"

### Problem

Your code must interact with a sophisticated library that requires initializing many objects and managing their dependencies. Tight coupling between business logic and third-party internals makes the code hard to understand and refactor.

### Solution

Create a Facade class with a simple interface exposing only what clients need. The facade hides initialization, sequencing, and inter-object communication of the subsystem. Clients depend on the facade instead of the subsystem.

**Incorrect (client orchestrates the subsystem directly):**

```typescript
// Every caller of "play a video" has to know this whole dance:
const codec   = CodecFactory.extract(filename);
const buffer  = new VideoBufferReader(filename, codec);
const bitrate = BitrateReader.read(buffer, codec);
const audio   = AudioMixer.process(buffer);
const player  = new VideoPlayer();
player.init(codec, audio);
player.play(bitrate);
player.teardown();
```

**Correct (one facade, callers say `play(filename)`):**

```typescript
/**
 * The Facade class provides a simple interface to the complex logic of one or
 * several subsystems. The Facade delegates the client requests to the
 * appropriate objects within the subsystem. The Facade is also responsible for
 * managing their lifecycle. All of this shields the client from the undesired
 * complexity of the subsystem.
 */
class Facade {
    protected subsystem1: Subsystem1;

    protected subsystem2: Subsystem2;

    /**
     * Depending on your application's needs, you can provide the Facade with
     * existing subsystem objects or force the Facade to create them on its own.
     */
    constructor(subsystem1?: Subsystem1, subsystem2?: Subsystem2) {
        this.subsystem1 = subsystem1 || new Subsystem1();
        this.subsystem2 = subsystem2 || new Subsystem2();
    }

    /**
     * The Facade's methods are convenient shortcuts to the sophisticated
     * functionality of the subsystems. However, clients get only to a fraction
     * of a subsystem's capabilities.
     */
    public operation(): string {
        let result = 'Facade initializes subsystems:\n';
        result += this.subsystem1.operation1();
        result += this.subsystem2.operation1();
        result += 'Facade orders subsystems to perform the action:\n';
        result += this.subsystem1.operationN();
        result += this.subsystem2.operationZ();

        return result;
    }
}

/**
 * The Subsystem can accept requests either from the facade or client directly.
 * In any case, to the Subsystem, the Facade is yet another client, and it's not
 * a part of the Subsystem.
 */
class Subsystem1 {
    public operation1(): string {
        return 'Subsystem1: Ready!\n';
    }

    public operationN(): string {
        return 'Subsystem1: Go!\n';
    }
}

/**
 * Some facades can work with multiple subsystems at the same time.
 */
class Subsystem2 {
    public operation1(): string {
        return 'Subsystem2: Get ready!\n';
    }

    public operationZ(): string {
        return 'Subsystem2: Fire!';
    }
}

function clientCode(facade: Facade) {
    console.log(facade.operation());
}

const subsystem1 = new Subsystem1();
const subsystem2 = new Subsystem2();
const facade = new Facade(subsystem1, subsystem2);
clientCode(facade);
```

**Output:**

```text
Facade initializes subsystems:
Subsystem1: Ready!
Subsystem2: Get ready!
Facade orders subsystems to perform the action:
Subsystem1: Go!
Subsystem2: Fire!
```

### When to use

- You need a simple interface over a complex subsystem
- You want to structure subsystems into layers, with facades as the entry point to each layer
- The same orchestration sequence repeats across multiple callers

### When NOT to use

- The subsystem is already simple — Facade adds indirection with no benefit
- You need fine-grained control over the subsystem — a Facade hides exactly that
- The Facade is on track to become a god object — split it into multiple smaller facades

### Implementation Steps

1. Determine whether a simpler interface than the existing subsystem is feasible
2. Declare the facade interface and implement it; route client calls to subsystem objects
3. Ensure all client code goes through the facade
4. If the facade grows too large, extract behavior into multiple refined facades

### Pros

- Isolates client code from subsystem complexity
- Reduces coupling — clients depend on the facade, not the subsystem

### Cons

- A facade can become a god object coupled to every subsystem class

### Related Patterns

- **Adapter** — Facade defines a *new* interface for an existing subsystem; Adapter makes one object match an *existing* interface
- **Abstract Factory** — can hide subsystem object creation from clients (alternative to Facade for the creation aspect)
- **Mediator** — Mediator centralizes communication among components; Facade just simplifies access without removing functionality
- **Singleton** — a Facade is often a Singleton because one is usually enough
- **Proxy** — Proxy keeps the same interface as the wrapped object; Facade defines a new one

Reference: [refactoring.guru/design-patterns/facade](https://refactoring.guru/design-patterns/facade)
