# TypeScript Design Patterns

**Version 0.1.0**  
Refactoring Guru  
May 2026

> **Note:** This document is for agents and LLMs maintaining, generating, or refactoring TypeScript Design Patterns code — the 22 Gang of Four patterns in TypeScript. Humans may also find it useful, but guidance here is optimized for AI-assisted workflows.

---

## Abstract

Implementation guide for the 22 Gang of Four design patterns with TypeScript examples, distilled from refactoring.guru. Each pattern reference covers intent, the problem it solves, the structural solution, applicability (when to use and when not to), a complete runnable TypeScript example with output, implementation steps, pros/cons, and relations to sibling patterns. Patterns are grouped by purpose: 5 Creational (Factory Method, Abstract Factory, Builder, Prototype, Singleton), 7 Structural (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy), and 10 Behavioral (Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor). Use this skill when you recognize a pattern-shaped problem — class explosion via inheritance, scattered conditionals branching on type, tight coupling between caller and concrete class, tree-shaped models, runtime algorithm selection, undo/redo, state-dependent behavior — and need a vetted structural recipe instead of inventing one.

---

## Table of Contents

1. [Creational Patterns](references/_sections.md#1-creational-patterns) — **HIGH**
   - 1.1 [Use Abstract Factory to Produce Families of Related Objects](references/creational-abstract-factory.md) — MEDIUM-HIGH (prevents mixing incompatible variants (e.g., Victorian chair with Modern sofa) by guaranteeing all objects returned from one factory belong to the same family, eliminates parallel `if (style === ...)` conditionals at every product-creation site)
   - 1.2 [Use Builder to Construct Complex Objects Step by Step](references/creational-builder.md) — HIGH (eliminates telescoping-constructor smell (constructors with 10+ parameters and many overloads), prevents subclass explosion for every parameter combination, allows the same construction sequence to produce different representations)
   - 1.3 [Use Factory Method to Decouple Object Creation from Concrete Classes](references/creational-factory-method.md) — HIGH (eliminates direct `new ConcreteX()` calls scattered through callers, isolates product instantiation so adding a new product type touches only one creator subclass instead of every call site)
   - 1.4 [Use Prototype to Clone Objects Without Coupling to Concrete Classes](references/creational-prototype.md) — MEDIUM (enables copying complex pre-configured objects through a common `clone()` interface, preserves access to private fields that external copy code cannot reach, removes the need for parallel "copy constructor" subclasses)
   - 1.5 [Use Singleton to Guarantee a Single Shared Instance](references/creational-singleton.md) — MEDIUM (enforces exactly one instance of a shared resource (config, registry, connection pool, logger), prevents accidental duplicate instantiation that diverges state, and provides a single named access point that's easy to find and replace)
2. [Structural Patterns](references/_sections.md#2-structural-patterns) — **HIGH**
   - 2.1 [Use Adapter to Make Incompatible Interfaces Cooperate](references/structural-adapter.md) — HIGH (enables reusing existing classes whose interface doesn't match what callers expect, eliminates ad-hoc conversion code scattered across call sites, isolates third-party API translation in one class)
   - 2.2 [Use Bridge to Split Abstraction from Implementation](references/structural-bridge.md) — MEDIUM (prevents exponential subclass explosion when a class varies along two or more independent dimensions, allows abstraction and implementation hierarchies to evolve separately, enables runtime swapping of implementations)
   - 2.3 [Use Composite to Treat Trees and Leaves Uniformly](references/structural-composite.md) — HIGH (eliminates `instanceof` and type-discrimination throughout traversal code, enables recursive operations across object trees through a single interface, lets clients work with arbitrarily nested structures without knowing the nesting level)
   - 2.4 [Use Decorator to Attach Behaviors at Runtime via Wrappers](references/structural-decorator.md) — HIGH (reduces N×M subclass explosion (channels × combinations like EmailWithSmsWithSlack) to N small decorators, eliminates duplicated wrapping code, enables adding or removing responsibilities dynamically)
   - 2.5 [Use Facade to Hide a Complex Subsystem Behind One Interface](references/structural-facade.md) — HIGH (replaces sprawling client code that orchestrates many subsystem objects with a single entry-point class, reduces coupling between application code and third-party library internals, eliminates duplicated initialization sequences across callers)
   - 2.6 [Use Flyweight to Share Common State Across Many Objects](references/structural-flyweight.md) — LOW-MEDIUM (drastically reduces memory footprint when spawning millions of similar objects (game particles, cell sprites, text glyphs) by sharing immutable intrinsic state and passing variable extrinsic state per call)
   - 2.7 [Use Proxy to Insert a Substitute Controlling Access to an Object](references/structural-proxy.md) — MEDIUM-HIGH (enables lazy loading, access control, caching, and logging without modifying the real subject or duplicating that logic at every call site, preserves the original interface so callers remain unchanged)
3. [Behavioral Patterns](references/_sections.md#3-behavioral-patterns) — **HIGH**
   - 3.1 [Use Chain of Responsibility to Pass Requests Through Handlers](references/behavioral-chain-of-responsibility.md) — MEDIUM-HIGH (replaces hardcoded validation/auth/parsing pipelines with composable handler chains, enables reordering or adding new handlers at runtime without modifying others, eliminates deeply nested if/else cascades that obscure pipeline intent)
   - 3.2 [Use Command to Turn Requests into Stand-Alone Objects](references/behavioral-command.md) — HIGH (enables undo/redo, queueing, scheduling, and macro recording by reifying requests as objects, decouples the invoker (button, shortcut, menu) from the receiver (business logic), eliminates duplicated invocation logic across UI surfaces)
   - 3.3 [Use Iterator to Traverse Collections Without Exposing Their Internals](references/behavioral-iterator.md) — HIGH (hides collection representation from callers (list, tree, graph, stream all look the same), enables multiple independent traversals over the same collection, eliminates duplicated traversal code throughout the application)
   - 3.4 [Use Mediator to Replace Many-to-Many Coupling with a Hub](references/behavioral-mediator.md) — MEDIUM (reduces N×N component dependencies to N×1 by routing all communication through a single mediator, makes components reusable in other contexts since they no longer reference each other directly)
   - 3.5 [Use Memento to Snapshot State Without Breaking Encapsulation](references/behavioral-memento.md) — LOW-MEDIUM (captures restorable snapshots of an originator's state through a narrow interface so the caretaker (history, transaction log) can store them without ever seeing the private fields, preserves encapsulation that exposing getters would violate)
   - 3.6 [Use Observer to Broadcast State Changes to Many Subscribers](references/behavioral-observer.md) — CRITICAL (enables one-to-many notification of state changes without the publisher knowing its subscribers — foundational to event systems, reactive UI frameworks, pub/sub, and dataflow programming)
   - 3.7 [Use State to Alter Behavior When Internal State Changes](references/behavioral-state.md) — MEDIUM-HIGH (replaces sprawling `switch(state)` blocks in every method with polymorphic state objects, eliminates the bug-prone duplication of state checks across an object's methods, makes adding a new state a single new class instead of editing every method)
   - 3.8 [Use Strategy to Make Algorithms Interchangeable at Runtime](references/behavioral-strategy.md) — HIGH (eliminates `if (type === 'a') ... else if (type === 'b')` algorithm-selection conditionals scattered through business code, enables runtime swapping of algorithm variants, isolates each algorithm in its own class for independent testing and reuse)
   - 3.9 [Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps](references/behavioral-template-method.md) — MEDIUM (eliminates duplicated algorithm scaffolding across sibling classes by hoisting the shared sequence into a base class, lets subclasses override only the steps that legitimately vary, removes client conditionals that switch on subclass type)
   - 3.10 [Use Visitor to Add Operations to Class Hierarchies Without Modifying Them](references/behavioral-visitor.md) — LOW-MEDIUM (enables adding new operations (export, validate, render, optimize) across a closed object hierarchy by writing a new visitor class instead of editing every node type, isolates each new operation in one place rather than scattering it across the hierarchy)

---

## References

1. [https://refactoring.guru/design-patterns/catalog](https://refactoring.guru/design-patterns/catalog)
2. [https://refactoring.guru/design-patterns/typescript](https://refactoring.guru/design-patterns/typescript)
3. [https://refactoring.guru/design-patterns/creational-patterns](https://refactoring.guru/design-patterns/creational-patterns)
4. [https://refactoring.guru/design-patterns/structural-patterns](https://refactoring.guru/design-patterns/structural-patterns)
5. [https://refactoring.guru/design-patterns/behavioral-patterns](https://refactoring.guru/design-patterns/behavioral-patterns)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |