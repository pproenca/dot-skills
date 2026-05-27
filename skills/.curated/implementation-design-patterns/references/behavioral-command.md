---
title: Use Command to Turn Requests into Stand-Alone Objects
impact: HIGH
impactDescription: enables undo/redo, queueing, scheduling, and macro recording by reifying requests as objects, decouples the invoker (button, shortcut, menu) from the receiver (business logic), eliminates duplicated invocation logic across UI surfaces
tags: behavioral, command, undo-redo, queueing, invoker-receiver-decoupling
---

## Use Command to Turn Requests into Stand-Alone Objects

**Pattern intent:** encapsulate a request as an object, letting you parameterize clients with different requests, queue or log requests, and support undoable operations. The invoker triggers a command; the command knows which receiver to invoke.

### Shapes to recognize

- Same operation triggered from multiple UI surfaces (button, menu item, shortcut, drag handler) — each currently re-implements the logic
- Need to record, queue, schedule, or replay user actions
- Need to undo/redo operations
- Need a transaction log: "what just happened?"
- "I want to pass an action around as a value" — a closure handles this in JS, but Command adds undo, serialization, identity

### Problem

GUI apps spawn button subclasses per action, coupling UI tightly to business logic. The same operation (copy/paste) must be invoked from toolbar buttons, context menus, and shortcuts — leading to duplicated logic.

### Solution

Extract a request's details into a Command object with a single `execute()` method. Each invoker holds a Command and triggers it without knowing what runs. Commands delegate the real work to Receiver objects holding the business logic. The same Command can be reused across invokers; commands can be queued, logged, or undone.

**Incorrect (UI elements re-implement business logic):**

```typescript
class CopyButton {
  onClick(doc: Document)  { /* same copy logic */ }
}
class CopyMenuItem {
  onClick(doc: Document)  { /* same copy logic */ }
}
class CopyShortcut {
  onTrigger(doc: Document) { /* same copy logic */ }
}
// Add Cut? Three more classes. No history, no undo.
```

**Correct (request reified as Command):**

```typescript
/**
 * The Command interface declares a method for executing a command.
 */
interface Command {
    execute(): void;
}

/**
 * Some commands can implement simple operations on their own.
 */
class SimpleCommand implements Command {
    private payload: string;

    constructor(payload: string) {
        this.payload = payload;
    }

    public execute(): void {
        console.log(`SimpleCommand: See, I can do simple things like printing (${this.payload})`);
    }
}

/**
 * However, some commands can delegate more complex operations to other objects,
 * called "receivers."
 */
class ComplexCommand implements Command {
    private receiver: Receiver;

    private a: string;

    private b: string;

    /**
     * Complex commands can accept one or several receiver objects along with
     * any context data via the constructor.
     */
    constructor(receiver: Receiver, a: string, b: string) {
        this.receiver = receiver;
        this.a = a;
        this.b = b;
    }

    /**
     * Commands can delegate to any methods of a receiver.
     */
    public execute(): void {
        console.log('ComplexCommand: Complex stuff should be done by a receiver object.');
        this.receiver.doSomething(this.a);
        this.receiver.doSomethingElse(this.b);
    }
}

/**
 * The Receiver classes contain some important business logic. They know how to
 * perform all kinds of operations, associated with carrying out a request. In
 * fact, any class may serve as a Receiver.
 */
class Receiver {
    public doSomething(a: string): void {
        console.log(`Receiver: Working on (${a}.)`);
    }

    public doSomethingElse(b: string): void {
        console.log(`Receiver: Also working on (${b}.)`);
    }
}

/**
 * The Invoker is associated with one or several commands. It sends a request to
 * the command.
 */
class Invoker {
    private onStart?: Command;

    private onFinish?: Command;

    public setOnStart(command: Command): void {
        this.onStart = command;
    }

    public setOnFinish(command: Command): void {
        this.onFinish = command;
    }

    /**
     * The Invoker does not depend on concrete command or receiver classes. The
     * Invoker passes a request to a receiver indirectly, by executing a
     * command.
     */
    public doSomethingImportant(): void {
        console.log('Invoker: Does anybody want something done before I begin?');
        if (this.isCommand(this.onStart)) {
            this.onStart.execute();
        }

        console.log('Invoker: ...doing something really important...');

        console.log('Invoker: Does anybody want something done after I finish?');
        if (this.isCommand(this.onFinish)) {
            this.onFinish.execute();
        }
    }

    private isCommand(object: Command | undefined): object is Command {
        return object?.execute !== undefined;
    }
}

const invoker = new Invoker();
invoker.setOnStart(new SimpleCommand('Say Hi!'));
const receiver = new Receiver();
invoker.setOnFinish(new ComplexCommand(receiver, 'Send email', 'Save report'));

invoker.doSomethingImportant();
```

**Output:**

```text
Invoker: Does anybody want something done before I begin?
SimpleCommand: See, I can do simple things like printing (Say Hi!)
Invoker: ...doing something really important...
Invoker: Does anybody want something done after I finish?
ComplexCommand: Complex stuff should be done by a receiver object.
Receiver: Working on (Send email.)
Receiver: Also working on (Save report.)
```

### When to use

- Parameterize objects with operations (callbacks with identity and state)
- Queue operations, schedule execution, or execute remotely
- Implement reversible (undo/redo) operations with a history stack
- Decouple senders (UI) from receivers (business logic)

### When NOT to use

- A plain function or closure suffices — JavaScript functions are first-class
- No undo, no queueing, no logging — just pass a function
- A single short-lived call site — Command is overhead

### Implementation Steps

1. Declare the Command interface with `execute()`
2. Extract each request into a concrete Command class implementing the interface
3. Identify sender (invoker) classes; add fields storing Commands
4. Change senders to execute Commands instead of calling business logic directly
5. Initialize in order: receivers → commands → senders

### Pros

- Single Responsibility Principle: decouples invokers from performers
- Open/Closed Principle: introduce new commands without breaking existing code
- Implement undo/redo and deferred execution
- Assemble simple commands into composite ones

### Cons

- Code complexity increases due to the additional indirection layer

### Related Patterns

- **Chain of Responsibility / Mediator / Observer** — alternative ways to connect senders and receivers
- **Memento** — pair with Command to implement undo (snapshot before execute)
- **Strategy** — Strategy varies an algorithm; Command reifies a request
- **Visitor** — extends Command to operate across different object types

Reference: [refactoring.guru/design-patterns/command](https://refactoring.guru/design-patterns/command)
