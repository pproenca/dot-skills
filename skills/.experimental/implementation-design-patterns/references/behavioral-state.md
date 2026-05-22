---
title: Use State to Alter Behavior When Internal State Changes
impact: MEDIUM-HIGH
impactDescription: replaces sprawling `switch(state)` blocks in every method with polymorphic state objects, eliminates the bug-prone duplication of state checks across an object's methods, makes adding a new state a single new class instead of editing every method
tags: behavioral, state, state-machine, polymorphism, transition
---

## Use State to Alter Behavior When Internal State Changes

**Pattern intent:** allow an object to alter its behavior when its internal state changes. The object will appear to change its class. Each possible state becomes a separate class implementing a common state interface; the context delegates state-dependent behavior to the current state object.

### Shapes to recognize

- A class with several methods, each containing `switch (this.status) { ... }` covering the same set of states
- A workflow object (order, document, ticket) with status field and methods that act differently per status
- TCP connection, media player, finite state machine — anything where transitions matter
- "Adding a new state requires editing five methods"

### Problem

An object behaves differently based on its internal state, and the number of states is substantial. Without the State pattern, this typically results in massive conditional statements scattered through methods. Each new state forces edits across every method that branches on state.

### Solution

Create a separate class for each state. Move state-specific behavior into these classes. The context holds a reference to the current state object and delegates all state-dependent work to it. State objects can trigger transitions by handing the context a new state.

**Incorrect (every method branches on the same status field):**

```typescript
class Document {
  status: 'draft' | 'review' | 'published' = 'draft';

  publish() {
    switch (this.status) {
      case 'draft':     this.status = 'review'; break;
      case 'review':    this.status = 'published'; break;
      case 'published': break;
    }
  }

  reject() {
    switch (this.status) {
      case 'draft':     /* noop */ break;
      case 'review':    this.status = 'draft'; break;
      case 'published': /* can't reject */ break;
    }
  }

  // Each method repeats the same switch — adding 'archived' touches all of them.
}
```

**Correct (state objects with transitions):**

```typescript
/**
 * The Context defines the interface of interest to clients. It also maintains a
 * reference to an instance of a State subclass, which represents the current
 * state of the Context.
 */
class Context {
    private state!: State;

    constructor(state: State) {
        this.transitionTo(state);
    }

    /**
     * The Context allows changing the State object at runtime.
     */
    public transitionTo(state: State): void {
        console.log(`Context: Transition to ${(<any>state).constructor.name}.`);
        this.state = state;
        this.state.setContext(this);
    }

    /**
     * The Context delegates part of its behavior to the current State object.
     */
    public request1(): void {
        this.state.handle1();
    }

    public request2(): void {
        this.state.handle2();
    }
}

/**
 * The base State class declares methods that all Concrete State should
 * implement and also provides a backreference to the Context object, associated
 * with the State. This backreference can be used by States to transition the
 * Context to another State.
 */
abstract class State {
    protected context!: Context;

    public setContext(context: Context) {
        this.context = context;
    }

    public abstract handle1(): void;

    public abstract handle2(): void;
}

/**
 * Concrete States implement various behaviors, associated with a state of the
 * Context.
 */
class ConcreteStateA extends State {
    public handle1(): void {
        console.log('ConcreteStateA handles request1.');
        console.log('ConcreteStateA wants to change the state of the context.');
        this.context.transitionTo(new ConcreteStateB());
    }

    public handle2(): void {
        console.log('ConcreteStateA handles request2.');
    }
}

class ConcreteStateB extends State {
    public handle1(): void {
        console.log('ConcreteStateB handles request1.');
    }

    public handle2(): void {
        console.log('ConcreteStateB handles request2.');
        console.log('ConcreteStateB wants to change the state of the context.');
        this.context.transitionTo(new ConcreteStateA());
    }
}

const context = new Context(new ConcreteStateA());
context.request1();
context.request2();
```

**Output:**

```text
Context: Transition to ConcreteStateA.
ConcreteStateA handles request1.
ConcreteStateA wants to change the state of the context.
Context: Transition to ConcreteStateB.
ConcreteStateB handles request2.
ConcreteStateB wants to change the state of the context.
Context: Transition to ConcreteStateA.
```

### When to use

- An object behaves differently based on internal state, and the number of states is substantial
- Classes contain massive conditionals that alter behavior based on a state field
- Significant duplicate code exists across similar states and transitions

### When NOT to use

- Two or three states with trivial differences — a small switch suffices
- States rarely change and behavior overlap is high
- A pure data-driven state table is simpler than a class hierarchy for your case

### Implementation Steps

1. Identify the context class needing state-dependent behavior
2. Declare a state interface with the relevant methods
3. Create concrete state classes implementing the interface
4. Add a state reference field and setter to the context
5. Replace conditional logic in context methods with calls to the state object
6. Implement transitions by instantiating and assigning new state objects (from inside states or from the context)

### Pros

- Single Responsibility: state-specific code lives in one place per state
- Open/Closed: add new states without modifying existing ones
- Eliminates bulky conditionals from the context

### Cons

- Can be overkill for simple machines with few states

### Related Patterns

- **Strategy** — same composition shape; Strategy objects are independent and the client picks one. State objects know each other and trigger transitions on the context.
- **Bridge** — also composition-based, but Bridge splits abstraction from implementation along two orthogonal axes
- **Memento** — capture state snapshots for rollback alongside State

Reference: [refactoring.guru/design-patterns/state](https://refactoring.guru/design-patterns/state)
