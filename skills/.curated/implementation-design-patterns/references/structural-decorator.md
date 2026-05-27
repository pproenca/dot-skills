---
title: Use Decorator to Attach Behaviors at Runtime via Wrappers
impact: HIGH
impactDescription: reduces N×M subclass explosion (channels × combinations like EmailWithSmsWithSlack) to N small decorators, eliminates duplicated wrapping code, enables adding or removing responsibilities dynamically
tags: structural, decorator, wrapper, composition-over-inheritance, layering
---

## Use Decorator to Attach Behaviors at Runtime via Wrappers

**Pattern intent:** attach new responsibilities to an object by wrapping it in another object that shares the same interface. Multiple decorators can stack, each adding a layer of behavior, while the client still talks to the original interface.

### Shapes to recognize

- A subclass per combination of behaviors: `EmailNotifier`, `EmailWithSMSNotifier`, `EmailWithSlackNotifier`, `EmailWithSMSAndSlackNotifier`...
- Need to combine behaviors at runtime based on user settings or configuration
- Cross-cutting concerns (logging, caching, encryption, compression, auth) you want to apply to *some* objects, not all
- "I need to add a feature to this object without changing it"

### Problem

A notification library starts with email only, then needs SMS, Facebook, Slack. Subclassing every combination yields a combinatorial explosion. Inheritance fixes behavior at compile time and forces final-class hierarchies.

### Solution

Create a base decorator class that holds a reference to a wrapped component and implements the same interface. Each concrete decorator overrides methods to add behavior before or after delegating to the wrapped object. Clients build a chain by wrapping objects in decorators in the desired order.

**Incorrect (subclass per combination):**

```typescript
class EmailNotifier                                   { send(msg: string) { /* email */ } }
class EmailWithSmsNotifier         extends EmailNotifier { send(msg: string) { /* email + sms */ } }
class EmailWithSlackNotifier       extends EmailNotifier { send(msg: string) { /* email + slack */ } }
class EmailWithSmsAndSlackNotifier extends EmailNotifier { send(msg: string) { /* email + sms + slack */ } }
// Add Facebook? Now 8 subclasses. Add Push? 16. Combinatorial.
```

**Correct (layered wrappers composed at runtime):**

```typescript
/**
 * The base Component interface defines operations that can be altered by
 * decorators.
 */
interface Component {
    operation(): string;
}

/**
 * Concrete Components provide default implementations of the operations. There
 * might be several variations of these classes.
 */
class ConcreteComponent implements Component {
    public operation(): string {
        return 'ConcreteComponent';
    }
}

/**
 * The base Decorator class follows the same interface as the other components.
 * The primary purpose of this class is to define the wrapping interface for all
 * concrete decorators. The default implementation of the wrapping code might
 * include a field for storing a wrapped component and the means to initialize
 * it.
 */
class Decorator implements Component {
    protected component: Component;

    constructor(component: Component) {
        this.component = component;
    }

    public operation(): string {
        return this.component.operation();
    }
}

/**
 * Concrete Decorators call the wrapped object and alter its result in some way.
 */
class ConcreteDecoratorA extends Decorator {
    public operation(): string {
        return `ConcreteDecoratorA(${super.operation()})`;
    }
}

/**
 * Decorators can execute their behavior either before or after the call to a
 * wrapped object.
 */
class ConcreteDecoratorB extends Decorator {
    public operation(): string {
        return `ConcreteDecoratorB(${super.operation()})`;
    }
}

function clientCode(component: Component) {
    console.log(`RESULT: ${component.operation()}`);
}

const simple = new ConcreteComponent();
console.log('Client: I\'ve got a simple component:');
clientCode(simple);
console.log('');

/**
 * Note how decorators can wrap not only simple components but the other
 * decorators as well.
 */
const decorator1 = new ConcreteDecoratorA(simple);
const decorator2 = new ConcreteDecoratorB(decorator1);
console.log('Client: Now I\'ve got a decorated component:');
clientCode(decorator2);
```

**Output:**

```text
Client: I've got a simple component:
RESULT: ConcreteComponent

Client: Now I've got a decorated component:
RESULT: ConcreteDecoratorB(ConcreteDecoratorA(ConcreteComponent))
```

### When to use

- Assign extra behaviors to objects at runtime without breaking existing code
- Structure business logic into composable, opt-in layers with consistent interfaces
- Extending objects where inheritance is awkward (final classes, single-parent limitation)

### When NOT to use

- Behavior order matters in subtle ways and the wrapping order is easy to get wrong
- You need to remove a specific wrapper from the middle of a stack — Decorator chains aren't designed for that
- The base class is fine — adding decorators just for symmetry is dead weight

### Implementation Steps

1. Define the primary component interface
2. Create the concrete component(s) with base behavior
3. Create a base decorator class that implements the component interface and holds a wrapped component
4. Create concrete decorators; each adds behavior before/after delegating to the wrapped object
5. Client code composes decorators in the desired order

### Pros

- Extend object behavior without subclassing
- Add/remove responsibilities at runtime
- Combine multiple behaviors via stacked decorators
- Single Responsibility Principle across small, focused classes

### Cons

- Difficult to remove a specific wrapper from the middle of the stack
- Behavior may depend on decorator order — surprising bugs when order changes
- Initial configuration code can be verbose

### Related Patterns

- **Adapter** — different interface; Decorator keeps the same interface
- **Proxy** — same wrapping shape; Proxy controls lifecycle/access, Decorator adds behavior recursively
- **Chain of Responsibility** — handlers may stop propagation; decorators don't
- **Composite** — recursive structure with multiple children; Decorator has one child and adds behavior

Reference: [refactoring.guru/design-patterns/decorator](https://refactoring.guru/design-patterns/decorator)
