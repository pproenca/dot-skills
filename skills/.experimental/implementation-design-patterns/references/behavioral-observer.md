---
title: Use Observer to Broadcast State Changes to Many Subscribers
impact: CRITICAL
impactDescription: enables one-to-many notification of state changes without the publisher knowing its subscribers — foundational to event systems, reactive UI frameworks, pub/sub, and dataflow programming
tags: behavioral, observer, pub-sub, event-system, reactive, publisher-subscriber
---

## Use Observer to Broadcast State Changes to Many Subscribers

**Pattern intent:** define a one-to-many dependency between objects so when one (the subject) changes state, all dependents (observers) are notified automatically. Subscribers subscribe and unsubscribe at runtime.

### Shapes to recognize

- Multiple parts of the system need to react when a value changes — UI re-render, log write, cache invalidation, analytics
- Polling: code that loops checking "did it change yet?" — replace with subscription
- DOM events, EventEmitter, RxJS Observables, React state, Vue reactivity, signals — all instances of Observer in different clothing
- The publisher *must not know* what reacts to its changes — loose coupling is required

### Problem

Customers monitor product availability; visiting the store frequently wastes their time, and the store mass-emailing every customer spams uninterested ones. The system needs targeted notifications between independent parties.

### Solution

Add a subscription mechanism to the publisher: an `attach(observer)` and `detach(observer)` API plus a notification method. When the publisher's state changes, it iterates subscribers and calls a common `update(subject)` method on each.

**Incorrect (polling and tight coupling):**

```typescript
class Store {
  public inStock: boolean = false;
}

// Every interested party polls the store on a timer — wasteful and laggy.
const store = new Store();
setInterval(() => {
  if (store.inStock) sendEmail();
  if (store.inStock) updateUI();
  if (store.inStock) trackAnalytics();
}, 1000);
```

**Correct (publisher notifies subscribers on change):**

```typescript
/**
 * The Subject interface declares a set of methods for managing subscribers.
 */
interface Subject {
    // Attach an observer to the subject.
    attach(observer: Observer): void;

    // Detach an observer from the subject.
    detach(observer: Observer): void;

    // Notify all observers about an event.
    notify(): void;
}

/**
 * The Subject owns some important state and notifies observers when the state
 * changes.
 */
class ConcreteSubject implements Subject {
    public state: number;

    private observers: Observer[] = [];

    public attach(observer: Observer): void {
        const isExist = this.observers.includes(observer);
        if (isExist) {
            return console.log('Subject: Observer has been attached already.');
        }

        console.log('Subject: Attached an observer.');
        this.observers.push(observer);
    }

    public detach(observer: Observer): void {
        const observerIndex = this.observers.indexOf(observer);
        if (observerIndex === -1) {
            return console.log('Subject: Nonexistent observer.');
        }

        this.observers.splice(observerIndex, 1);
        console.log('Subject: Detached an observer.');
    }

    /**
     * Trigger an update in each subscriber.
     */
    public notify(): void {
        console.log('Subject: Notifying observers...');
        for (const observer of this.observers) {
            observer.update(this);
        }
    }

    /**
     * Usually, the subscription logic is only a fraction of what a Subject can
     * really do. Subjects commonly hold some important business logic, that
     * triggers a notification method whenever something important is about to
     * happen (or after it).
     */
    public someBusinessLogic(): void {
        console.log('\nSubject: I\'m doing something important.');
        this.state = Math.floor(Math.random() * (10 + 1));

        console.log(`Subject: My state has just changed to: ${this.state}`);
        this.notify();
    }
}

/**
 * The Observer interface declares the update method, used by subjects.
 */
interface Observer {
    update(subject: Subject): void;
}

/**
 * Concrete Observers react to the updates issued by the Subject they had been
 * attached to.
 */
class ConcreteObserverA implements Observer {
    public update(subject: Subject): void {
        if (subject instanceof ConcreteSubject && subject.state < 3) {
            console.log('ConcreteObserverA: Reacted to the event.');
        }
    }
}

class ConcreteObserverB implements Observer {
    public update(subject: Subject): void {
        if (subject instanceof ConcreteSubject && (subject.state === 0 || subject.state >= 2)) {
            console.log('ConcreteObserverB: Reacted to the event.');
        }
    }
}

const subject = new ConcreteSubject();

const observer1 = new ConcreteObserverA();
subject.attach(observer1);

const observer2 = new ConcreteObserverB();
subject.attach(observer2);

subject.someBusinessLogic();
subject.someBusinessLogic();

subject.detach(observer2);

subject.someBusinessLogic();
```

**Output (the random `state` numbers differ per run):**

```text
Subject: Attached an observer.
Subject: Attached an observer.

Subject: I'm doing something important.
Subject: My state has just changed to: 6
Subject: Notifying observers...
ConcreteObserverB: Reacted to the event.

Subject: I'm doing something important.
Subject: My state has just changed to: 1
Subject: Notifying observers...
ConcreteObserverA: Reacted to the event.
Subject: Detached an observer.

Subject: I'm doing something important.
Subject: My state has just changed to: 5
Subject: Notifying observers...
```

### When to use

- One object's state changes require updating others whose set is unknown beforehand or changes dynamically
- GUI events where custom code hooks into widgets
- Cross-cutting reactions (logging, audit, analytics) that shouldn't pollute the publisher

### When NOT to use

- The set of subscribers is fixed and tiny — direct calls are simpler
- You need ordered, synchronous, transactional updates — Observer fires in registration order without guarantees
- The publisher needs to *coordinate* (not just notify) — reach for **Mediator** instead
- TypeScript shortcut: an `EventEmitter`, `EventTarget`, RxJS `Subject`, or a framework's reactive primitives often replaces a bespoke Observer

### Implementation Steps

1. Separate the business logic into publisher (core state) and subscribers (reactions)
2. Declare the subscriber interface with at least an `update` method
3. Declare the publisher interface with attach/detach/notify
4. Implement subscription methods in the publisher (or in an abstract base)
5. Concrete publishers call `notify()` when important state changes
6. Implement concrete subscribers' `update()` methods
7. Client wires subscribers to publishers at startup

### Pros

- Open/Closed Principle: add new subscriber types without modifying the publisher
- Establish dynamic relationships at runtime

### Cons

- Subscribers are notified in registration order (or unspecified order in some implementations)
- Memory leaks if subscribers forget to unsubscribe
- Debugging cascading updates can be hard

### Related Patterns

- **Chain of Responsibility / Command / Mediator** — alternative connection mechanisms
- **Mediator** — eliminates mutual dependencies via a hub; Observer establishes dynamic one-way connections; Mediator can be implemented using Observer internally

Reference: [refactoring.guru/design-patterns/observer](https://refactoring.guru/design-patterns/observer)
