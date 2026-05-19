---
title: Use Mediator to Replace Many-to-Many Coupling with a Hub
impact: MEDIUM
impactDescription: reduces N×N component dependencies to N×1 by routing all communication through a single mediator, makes components reusable in other contexts since they no longer reference each other directly
tags: behavioral, mediator, decoupling, communication-hub, coordination
---

## Use Mediator to Replace Many-to-Many Coupling with a Hub

**Pattern intent:** reduce chaotic dependencies between objects by routing their communication through a mediator. Components don't reference each other — they notify the mediator, which decides what should happen next.

### Shapes to recognize

- Form fields, dialog buttons, or UI components that import and directly invoke each other — N² couplings
- Components that can't be reused in another context because they're hardcoded to specific colleagues
- A god-controller that already exists informally — every component already calls it for everything
- "Changing field A breaks fields B and C because they listen to A directly"

### Problem

As an application evolves, form-element interactions become complex. Components grow tightly coupled, making them hard to reuse in new contexts because they're interdependent on specific colleagues.

### Solution

Components stop communicating directly. Each component holds a reference only to the Mediator and notifies it about events. The mediator decides which other components should react and invokes them. Components stay independent of each other.

**Incorrect (every component imports every other component):**

```typescript
class CityField {
  constructor(private countryField: CountryField, private zipField: ZipField) {}
  onChange(city: string) {
    this.countryField.update(city); // direct dependency
    this.zipField.update(city);     // direct dependency
  }
}
// Adding a new field requires editing CityField (and every other field that should know).
```

**Correct (mediator routes traffic):**

```typescript
/**
 * The Mediator interface declares a method used by components to notify the
 * mediator about various events. The Mediator may react to these events and
 * pass the execution to other components.
 */
interface Mediator {
    notify(sender: object, event: string): void;
}

/**
 * Concrete Mediators implement cooperative behavior by coordinating several
 * components.
 */
class ConcreteMediator implements Mediator {
    private component1: Component1;

    private component2: Component2;

    constructor(c1: Component1, c2: Component2) {
        this.component1 = c1;
        this.component1.setMediator(this);
        this.component2 = c2;
        this.component2.setMediator(this);
    }

    public notify(sender: object, event: string): void {
        if (event === 'A') {
            console.log('Mediator reacts on A and triggers following operations:');
            this.component2.doC();
        }

        if (event === 'D') {
            console.log('Mediator reacts on D and triggers following operations:');
            this.component1.doB();
            this.component2.doC();
        }
    }
}

/**
 * The Base Component provides the basic functionality of storing a mediator's
 * instance inside component objects.
 */
class BaseComponent {
    protected mediator: Mediator;

    constructor(mediator?: Mediator) {
        this.mediator = mediator!;
    }

    public setMediator(mediator: Mediator): void {
        this.mediator = mediator;
    }
}

/**
 * Concrete Components implement various functionality. They don't depend on
 * other components. They also don't depend on any concrete mediator classes.
 */
class Component1 extends BaseComponent {
    public doA(): void {
        console.log('Component 1 does A.');
        this.mediator.notify(this, 'A');
    }

    public doB(): void {
        console.log('Component 1 does B.');
        this.mediator.notify(this, 'B');
    }
}

class Component2 extends BaseComponent {
    public doC(): void {
        console.log('Component 2 does C.');
        this.mediator.notify(this, 'C');
    }

    public doD(): void {
        console.log('Component 2 does D.');
        this.mediator.notify(this, 'D');
    }
}

const c1 = new Component1();
const c2 = new Component2();
const mediator = new ConcreteMediator(c1, c2);

console.log('Client triggers operation A.');
c1.doA();

console.log('');
console.log('Client triggers operation D.');
c2.doD();
```

**Output:**

```text
Client triggers operation A.
Component 1 does A.
Mediator reacts on A and triggers following operations:
Component 2 does C.

Client triggers operation D.
Component 2 does D.
Mediator reacts on D and triggers following operations:
Component 1 does B.
Component 2 does C.
```

### When to use

- Classes are tightly coupled and difficult to modify in isolation
- Components can't be reused because they depend on too many colleagues
- You're creating many component subclasses just to swap collaborators in different contexts

### When NOT to use

- The mediator already exists implicitly and is small — formalizing it adds ceremony
- Components only communicate one-to-one, predictably — direct references are simpler
- The mediator is becoming a god object — split into focused mediators or revisit the design

### Implementation Steps

1. Identify tightly coupled classes that would benefit from independence
2. Declare the mediator interface describing the communication protocol
3. Implement the concrete mediator and have it hold references to components
4. Optionally make the mediator responsible for component creation/destruction
5. Components hold a reference to the mediator (typically via constructor)
6. Refactor components to notify the mediator instead of calling other components

### Pros

- Centralizes communication (Single Responsibility)
- New mediators introduce new coordination logic without modifying components (Open/Closed)
- Reduces coupling between components
- Components become reusable

### Cons

- Mediators can evolve into a god object over time

### Related Patterns

- **Chain of Responsibility / Command / Observer** — alternative ways to connect senders and receivers
- **Facade** — similar shape, but Facade *simplifies* access to a subsystem without introducing new coordination logic, while Mediator *centralizes* mutual communication
- **Observer** — Mediator eliminates mutual dependencies via a hub; Observer establishes dynamic one-way connections; mediators sometimes use Observer internally

Reference: [refactoring.guru/design-patterns/mediator](https://refactoring.guru/design-patterns/mediator)
