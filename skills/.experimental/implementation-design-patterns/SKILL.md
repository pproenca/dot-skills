---
name: implementation-design-patterns
description: Implementation guide for the 22 Gang of Four design patterns in TypeScript, distilled from refactoring.guru. Use this skill when writing, refactoring, or reviewing TypeScript that exhibits a pattern-shaped problem — class-explosion from inheritance, conditionals switching on type, tight coupling to concrete classes, tree-shaped models, runtime algorithm selection, undo/redo, snapshot-and-restore, state-dependent behavior, subscriber notification, or hiding subsystem complexity. Each pattern entry includes intent, problem, solution, applicability (when to use AND when NOT to use), a runnable TypeScript example, implementation steps, pros/cons, and relations to sibling patterns. Trigger even when no pattern is named — cues like "class getting unwieldy," "giant switch," "swap implementations at runtime," "combinatorial subclasses," "need undo," or "traverse a tree" are pattern-shaped. Covers all 5 Creational, 7 Structural, and 10 Behavioral GoF patterns.
metadata:
  internal: true
---
# TypeScript Design Patterns Best Practices (Refactoring Guru)

Implementation reference for the 22 Gang of Four design patterns in TypeScript, distilled from refactoring.guru. Each of the **22 pattern files across 3 categories** captures intent, problem, solution, applicability, a runnable TypeScript example, implementation steps, pros/cons, and relations to sibling patterns.

The patterns are a *vocabulary for structural decisions*, not a prescription. Reach for a pattern only when its applicability criteria match the problem at hand — every pattern entry includes a **When NOT to Use** section to guard against over-engineering.

## When to Apply

- Refactoring a class that has grown unwieldy via inheritance — combinatorial subclasses, conditional branching on type, or a "god class" with many responsibilities
- Designing a new module whose collaborators are not yet fixed — you want to keep the interface stable while implementations vary
- Integrating an incompatible third-party API, library, or legacy class into existing code
- Modeling a tree-shaped domain (file systems, organization charts, expression ASTs, UI component trees) where leaves and branches must be treated uniformly
- Adding cross-cutting behavior at runtime — logging, caching, access control, decoration — without subclassing
- Selecting an algorithm or behavior variant at runtime based on configuration, user input, or environmental conditions
- Implementing undo/redo, history snapshots, transactional rollback, or scheduling/queueing of operations
- Coordinating many objects whose direct mutual references have become tangled — a hub that brokers communication
- Notifying many subscribers when something changes — event systems, reactive data flows
- Reviewing code that smells like a pattern is implicit (large switch on `kind`, parallel class hierarchies, identical algorithm skeletons across siblings) — make it explicit

## Rule Categories

| # | Category | Impact | Patterns | When to reach for this group |
|---|----------|--------|----------|------------------------------|
| 1 | **Creational** | HIGH | 5 | Object construction is non-trivial, varies by configuration, or risks tight coupling to concrete classes |
| 2 | **Structural** | HIGH | 7 | Composing classes/objects into larger structures while keeping parts substitutable |
| 3 | **Behavioral** | HIGH | 10 | Distributing responsibility and defining how objects collaborate at runtime |

## How to Use

1. **Recognize the shape.** Read the **Quick Reference** below and identify which pattern's intent matches your problem. Most pattern-shaped problems sound like one of the listed phrases.
2. **Read the pattern reference.** Open `references/{category}-{pattern}.md`. Confirm intent, then read **Applicability** and **When NOT to Use** before adopting.
3. **Adapt the example.** The TypeScript example uses pedagogical names (`ConcreteStrategyA`, `Receiver`). Rename to domain terms before merging.
4. **Check the relations.** Each entry ends with **Related Patterns** — siblings worth considering for the same problem.

## Quick Reference

### 1. Creational Patterns (object instantiation)

- [`creational-factory-method`](references/creational-factory-method.md) — Subclasses decide which concrete product to create. *"I need to add new product types without touching the creator code."* — **HIGH**
- [`creational-abstract-factory`](references/creational-abstract-factory.md) — Produce families of related objects together. *"My code must work with multiple matching variants (chair+sofa+table) and shouldn't mix families."* — **MEDIUM-HIGH**
- [`creational-builder`](references/creational-builder.md) — Construct complex objects step by step. *"My constructor has 10+ parameters or I have a telescoping-constructor smell."* — **HIGH**
- [`creational-prototype`](references/creational-prototype.md) — Clone objects through their own `clone()` method. *"I need to copy objects without depending on their concrete class."* — **MEDIUM**
- [`creational-singleton`](references/creational-singleton.md) — Guarantee a single shared instance with a global access point. *"I need exactly one instance of this class — config, registry, pool."* — **MEDIUM**

### 2. Structural Patterns (composition)

- [`structural-adapter`](references/structural-adapter.md) — Translate one interface to another. *"I need to use a library whose API doesn't match what my code expects."* — **HIGH**
- [`structural-bridge`](references/structural-bridge.md) — Split abstraction from implementation so they can vary independently. *"I have two orthogonal dimensions and the subclass count is exploding."* — **MEDIUM**
- [`structural-composite`](references/structural-composite.md) — Treat individual objects and compositions uniformly. *"I have a tree (folders/files, groups/items, components/children) and want one interface for leaves and branches."* — **HIGH**
- [`structural-decorator`](references/structural-decorator.md) — Wrap an object to add behavior without subclassing. *"I want to layer behaviors (logging + caching + auth) on the same interface at runtime."* — **HIGH**
- [`structural-facade`](references/structural-facade.md) — Expose a simple interface over a complex subsystem. *"My client code is tangled in initialization and orchestration of a third-party library."* — **HIGH**
- [`structural-flyweight`](references/structural-flyweight.md) — Share common state across many objects to save memory. *"I'm spawning millions of similar objects and running out of RAM."* — **LOW-MEDIUM**
- [`structural-proxy`](references/structural-proxy.md) — Substitute for another object to control access. *"I need lazy loading, access control, caching, or logging without touching the real subject."* — **MEDIUM-HIGH**

### 3. Behavioral Patterns (collaboration)

- [`behavioral-chain-of-responsibility`](references/behavioral-chain-of-responsibility.md) — Pass a request along a chain of handlers. *"I have a pipeline of validation / auth / parsing checks and want to add or reorder them dynamically."* — **MEDIUM-HIGH**
- [`behavioral-command`](references/behavioral-command.md) — Turn a request into a stand-alone object. *"I need undo/redo, queueing, scheduling, macro recording, or to decouple invoker from receiver."* — **HIGH**
- [`behavioral-iterator`](references/behavioral-iterator.md) — Traverse a collection without exposing its representation. *"I want clients to walk a structure without knowing if it's a list, tree, or graph."* — **HIGH**
- [`behavioral-mediator`](references/behavioral-mediator.md) — Centralize communication among components in a single hub. *"My form fields all reference each other directly and the coupling is unmanageable."* — **MEDIUM**
- [`behavioral-memento`](references/behavioral-memento.md) — Capture and restore an object's state without breaking encapsulation. *"I need snapshots for undo/redo or transactional rollback."* — **LOW-MEDIUM**
- [`behavioral-observer`](references/behavioral-observer.md) — Notify dependent objects when state changes. *"Many objects need to react when one object changes — events, reactive UI, pub/sub."* — **CRITICAL**
- [`behavioral-state`](references/behavioral-state.md) — Alter behavior when internal state changes. *"My class is a state machine with massive conditionals branching on a `status` field."* — **MEDIUM-HIGH**
- [`behavioral-strategy`](references/behavioral-strategy.md) — Make algorithms interchangeable at runtime. *"I have multiple algorithms (sort, route, pay, compress) and want to pick one without conditionals."* — **HIGH**
- [`behavioral-template-method`](references/behavioral-template-method.md) — Fix an algorithm's skeleton in a base class; subclasses override steps. *"Several classes share the same algorithm structure with minor step differences."* — **MEDIUM**
- [`behavioral-visitor`](references/behavioral-visitor.md) — Add operations to an object structure without modifying the classes. *"I'd need to add 5 unrelated operations across an AST but I can't touch the node classes."* — **LOW-MEDIUM**

## How to Choose Between Similar Patterns

Several patterns share a structural shape but solve different problems. Read each pattern's **Related Patterns** section, then apply these distinctions:

- **Adapter vs. Facade vs. Proxy vs. Decorator** — all four wrap a target. *Adapter* changes the interface. *Facade* simplifies a subsystem. *Proxy* keeps the interface and controls access/lifecycle. *Decorator* keeps the interface and adds behavior recursively.
- **Strategy vs. State** — both swap a delegated object. *Strategy* objects are independent; the client picks one. *State* objects know each other and trigger transitions on the context.
- **Strategy vs. Template Method** — both vary parts of an algorithm. *Strategy* uses composition (swap at runtime). *Template Method* uses inheritance (fixed at compile time).
- **Factory Method vs. Abstract Factory vs. Builder** — *Factory Method* returns one product through a single method. *Abstract Factory* returns a family of related products through several methods. *Builder* assembles one complex product step by step.
- **Composite vs. Decorator** — both wrap children recursively. *Composite* sums or aggregates child results. *Decorator* adds responsibilities and passes through.
- **Chain of Responsibility vs. Command vs. Mediator vs. Observer** — all connect senders and receivers. *CoR* passes a request along a chain. *Command* makes the request a first-class object. *Mediator* centralizes mutual communication. *Observer* establishes one-publisher-to-many-subscribers notification.

## References

1. [Refactoring Guru — Design Patterns Catalog](https://refactoring.guru/design-patterns/catalog)
2. [Refactoring Guru — TypeScript Examples](https://refactoring.guru/design-patterns/typescript)
3. [Refactoring Guru — Creational Patterns](https://refactoring.guru/design-patterns/creational-patterns)
4. [Refactoring Guru — Structural Patterns](https://refactoring.guru/design-patterns/structural-patterns)
5. [Refactoring Guru — Behavioral Patterns](https://refactoring.guru/design-patterns/behavioral-patterns)
