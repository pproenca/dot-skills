---
title: Use Memento to Snapshot State Without Breaking Encapsulation
impact: LOW-MEDIUM
impactDescription: captures restorable snapshots of an originator's state through a narrow interface so the caretaker (history, transaction log) can store them without ever seeing the private fields, preserves encapsulation that exposing getters would violate
tags: behavioral, memento, snapshot, undo, encapsulation
---

## Use Memento to Snapshot State Without Breaking Encapsulation

**Pattern intent:** capture and externalize an object's state so it can be restored later, without revealing internal details. The originator produces mementos; a caretaker holds them; the originator alone reads from them.

### Shapes to recognize

- Need to implement undo/redo and your object's state is private — you can't just copy fields from outside
- Transaction rollback: a "before" snapshot must be captured before a risky operation
- Editor history (text, drawing, spreadsheet) where each user action becomes a restorable point
- Adding public getters everywhere just so external code can copy the object — encapsulation slipping

### Problem

A text editor needs undo, requiring state snapshots. Directly accessing private fields violates encapsulation; exposing every field via getters makes future refactors painful.

### Solution

The originator object creates immutable snapshots (mementos) of its own state. Only the originator has full access to the memento's contents; the caretaker interacts through a narrow interface (timestamp, label) and can't see internal state.

**Incorrect (encapsulation broken to support undo):**

```typescript
class Editor {
  // Was private — now public so the history can copy it. Encapsulation gone.
  public content: string = '';
  public cursor: number = 0;
  public selection: [number, number] | null = null;
}

class History {
  private snapshots: { content: string; cursor: number; selection: [number, number] | null }[] = [];
  save(editor: Editor) {
    // History knows every internal field — adding a field forces editing History.
    this.snapshots.push({
      content: editor.content,
      cursor: editor.cursor,
      selection: editor.selection,
    });
  }
}
```

**Correct (originator produces opaque mementos; caretaker only stores them):**

```typescript
/**
 * The Originator holds some important state that may change over time. It also
 * defines a method for saving the state inside a memento and another method for
 * restoring the state from it.
 */
class Originator {
    private state: string;

    constructor(state: string) {
        this.state = state;
        console.log(`Originator: My initial state is: ${state}`);
    }

    /**
     * The Originator's business logic may affect its internal state. Therefore,
     * the client should backup the state before launching methods of the
     * business logic via the save() method.
     */
    public doSomething(): void {
        console.log('Originator: I\'m doing something important.');
        this.state = this.generateRandomString(30);
        console.log(`Originator: and my state has changed to: ${this.state}`);
    }

    private generateRandomString(length: number = 10): string {
        const charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

        return Array
            .apply(null, { length })
            .map(() => charSet.charAt(Math.floor(Math.random() * charSet.length)))
            .join('');
    }

    /**
     * Saves the current state inside a memento.
     */
    public save(): Memento {
        return new ConcreteMemento(this.state);
    }

    /**
     * Restores the Originator's state from a memento object.
     */
    public restore(memento: Memento): void {
        this.state = memento.getState();
        console.log(`Originator: My state has changed to: ${this.state}`);
    }
}

/**
 * The Memento interface provides a way to retrieve the memento's metadata, such
 * as creation date or name. However, it doesn't expose the Originator's state.
 */
interface Memento {
    getState(): string;

    getName(): string;

    getDate(): string;
}

/**
 * The Concrete Memento contains the infrastructure for storing the Originator's
 * state.
 */
class ConcreteMemento implements Memento {
    private state: string;

    private date: string;

    constructor(state: string) {
        this.state = state;
        this.date = new Date().toISOString().slice(0, 19).replace('T', ' ');
    }

    /**
     * The Originator uses this method when restoring its state.
     */
    public getState(): string {
        return this.state;
    }

    /**
     * The rest of the methods are used by the Caretaker to display metadata.
     */
    public getName(): string {
        return `${this.date} / (${this.state.substr(0, 9)}...)`;
    }

    public getDate(): string {
        return this.date;
    }
}

/**
 * The Caretaker doesn't depend on the Concrete Memento class. Therefore, it
 * doesn't have access to the originator's state, stored inside the memento. It
 * works with all mementos via the base Memento interface.
 */
class Caretaker {
    private mementos: Memento[] = [];

    private originator: Originator;

    constructor(originator: Originator) {
        this.originator = originator;
    }

    public backup(): void {
        console.log('\nCaretaker: Saving Originator\'s state...');
        this.mementos.push(this.originator.save());
    }

    public undo(): void {
        if (!this.mementos.length) {
            return;
        }
        const memento = this.mementos.pop();

        console.log(`Caretaker: Restoring state to: ${memento.getName()}`);
        this.originator.restore(memento);
    }

    public showHistory(): void {
        console.log('Caretaker: Here\'s the list of mementos:');
        for (const memento of this.mementos) {
            console.log(memento.getName());
        }
    }
}

const originator = new Originator('Super-duper-super-puper-super.');
const caretaker = new Caretaker(originator);

caretaker.backup();
originator.doSomething();

caretaker.backup();
originator.doSomething();

caretaker.backup();
originator.doSomething();

console.log('');
caretaker.showHistory();

console.log('\nClient: Now, let\'s rollback!\n');
caretaker.undo();

console.log('\nClient: Once more!\n');
caretaker.undo();
```

**Output (the random strings will differ between runs):**

```text
Originator: My initial state is: Super-duper-super-puper-super.

Caretaker: Saving Originator's state...
Originator: I'm doing something important.
Originator: and my state has changed to: qXqxgTcLSCeLYdcgElOghOFhPGfMxo

Caretaker: Saving Originator's state...
Originator: I'm doing something important.
Originator: and my state has changed to: iaVCJVryJwWwbipieensfodeMSWvUY

Caretaker: Saving Originator's state...
Originator: I'm doing something important.
Originator: and my state has changed to: oSUxsOCiZEnohBMQEjwnPWJLGnwGmy

Caretaker: Here's the list of mementos:
2019-02-17 15:14:05 / (Super-dup...)
2019-02-17 15:14:05 / (qXqxgTcLS...)
2019-02-17 15:14:05 / (iaVCJVryJ...)

Client: Now, let's rollback!

Caretaker: Restoring state to: 2019-02-17 15:14:05 / (iaVCJVryJ...)
Originator: My state has changed to: iaVCJVryJwWwbipieensfodeMSWvUY

Client: Once more!

Caretaker: Restoring state to: 2019-02-17 15:14:05 / (qXqxgTcLS...)
Originator: My state has changed to: qXqxgTcLSCeLYdcgElOghOFhPGfMxo
```

### When to use

- Produce snapshots to restore previous object states
- Implement transaction rollback on errors
- Keep full copies of private fields separate from the object
- Direct field access would violate encapsulation

### When NOT to use

- The object is immutable and small — copying it directly is simpler than introducing a memento
- Snapshots would consume too much memory and you can't bound history length
- A higher-level event-sourcing or CRDT approach already gives you replay/undo

### Implementation Steps

1. Identify which class is the originator
2. Create a memento class mirroring the originator's relevant fields
3. Make the memento immutable — set state only via the constructor
4. Nest the memento inside the originator (or expose a narrow interface) so only the originator sees state
5. Add `save()` returning a memento and `restore(memento)` to the originator
6. Implement a caretaker that requests and stores mementos
7. Decide on memento lifecycle (history length, garbage collection)

### Pros

- Produce snapshots without violating encapsulation
- Simplifies the originator by delegating history management to the caretaker

### Cons

- Excessive mementos consume significant RAM
- Caretakers must track originator lifecycles to clean obsolete mementos
- Dynamic languages can't fully guarantee immutability inside mementos

### Related Patterns

- **Command** — pair with Memento for undo: snapshot before execute, restore on undo
- **Iterator** — capture and rollback iteration state
- **Prototype** — simpler alternative for straightforward, mostly-public-state objects

Reference: [refactoring.guru/design-patterns/memento](https://refactoring.guru/design-patterns/memento)
