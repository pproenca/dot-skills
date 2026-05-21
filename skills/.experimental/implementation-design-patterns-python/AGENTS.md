# Python Design Patterns

**Version 0.1.0**  
Refactoring Guru  
May 2026

> **Note:** This document is for agents and LLMs maintaining, generating, or refactoring Python Design Patterns code — the 22 Gang of Four patterns in idiomatic modern Python. Humans may also find it useful, but guidance here is optimized for AI-assisted workflows.

---

## Abstract

Implementation guide for the 22 Gang of Four design patterns in idiomatic modern Python, distilled from refactoring.guru and adapted to current Python (3.10+) idioms. Each reference leads with the Pythonic form — first-class functions and Callable, dataclasses, typing.Protocol, functools.singledispatch, structural pattern matching (match), generators, copy/dataclasses.replace, __slots__, weakref, descriptors, decorators — and falls back to the class-based GoF structure only where identity, registration, or polymorphic dispatch genuinely require it. Each pattern covers intent, the problem it solves, the structural solution, applicability (when to use and when not to), a runnable Python example with output, implementation steps, pros/cons, and relations to sibling patterns. Patterns are grouped by purpose: 5 Creational (Factory Method, Abstract Factory, Builder, Prototype, Singleton), 7 Structural (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy), and 10 Behavioral (Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor). Use this skill when you recognize a pattern-shaped problem in Python — class explosion via inheritance, scattered conditionals branching on type, tight coupling between caller and concrete class, tree-shaped models, runtime algorithm selection, undo/redo, state-dependent behavior — and want a vetted, idiomatic recipe instead of porting a Java-shaped class hierarchy.

---

## Table of Contents

1. [Creational Patterns](references/_sections.md#1-creational-patterns) — **HIGH**
   - 1.1 [Use Abstract Factory to Produce Families of Related Objects](references/creational-abstract-factory.md) — MEDIUM-HIGH (prevents mixing incompatible variants (a macOS checkbox with a Windows button) by guaranteeing every object from one factory belongs to the same family, eliminates parallel `if platform == ...` conditionals at each widget-creation site)
   - 1.2 [Use Builder to Construct Complex Objects Step by Step](references/creational-builder.md) — HIGH (eliminates the telescoping-constructor smell (an `__init__` with 10+ positional parameters and many `None` defaults), prevents subclass explosion for parameter combinations, enables the same construction sequence to produce different representations)
   - 1.3 [Use Factory Method to Decouple Object Creation from Concrete Classes](references/creational-factory-method.md) — HIGH (eliminates direct `Truck()`/`Ship()` constructor calls scattered through callers, isolates product instantiation so adding a new product type registers one class instead of editing every call site)
   - 1.4 [Use Prototype to Clone Objects Without Coupling to Concrete Classes](references/creational-prototype.md) — MEDIUM (enables copying complex pre-configured objects through `copy.deepcopy`/`dataclasses.replace` without a hand-written copy constructor, preserves nested mutable state automatically, removes the per-class copy code that silently rots when a field is added)
   - 1.5 [Use Singleton to Guarantee a Single Shared Instance](references/creational-singleton.md) — MEDIUM (enforces exactly one instance of a shared resource (config, registry, connection pool, logger) via module-import caching or `functools.cache`, prevents duplicate instantiation that diverges state, and keeps the object injectable for tests instead of a hidden global)
2. [Structural Patterns](references/_sections.md#2-structural-patterns) — **HIGH**
   - 2.1 [Use Adapter to Make Incompatible Interfaces Cooperate](references/structural-adapter.md) — HIGH (enables reusing a class whose interface doesn't match what callers expect, eliminates ad-hoc conversion code scattered across call sites, isolates the third-party API translation in one wrapper)
   - 2.2 [Use Bridge to Split Abstraction from Implementation](references/structural-bridge.md) — MEDIUM (prevents exponential subclass explosion when a type varies along two independent dimensions (control type x device type), lets the abstraction and implementation evolve separately, enables swapping the implementation at runtime)
   - 2.3 [Use Composite to Treat Trees and Leaves Uniformly](references/structural-composite.md) — HIGH (eliminates `isinstance` branching throughout traversal code, enables recursive operations across an object tree through one interface, lets clients work with arbitrarily nested structures without tracking depth)
   - 2.4 [Use Decorator to Attach Behaviors at Runtime via Wrappers](references/structural-decorator.md) — HIGH (reduces N x M subclass explosion (every combination like CompressedEncryptedStream) to a few small wrappers stacked at runtime, eliminates duplicated wrapping code, enables adding or removing responsibilities dynamically)
   - 2.5 [Use Facade to Hide a Complex Subsystem Behind One Interface](references/structural-facade.md) — HIGH (replaces sprawling client code that wires many subsystem objects with a single entry point, reduces coupling between application code and library internals, eliminates duplicated initialization sequences across callers)
   - 2.6 [Use Flyweight to Share Common State Across Many Objects](references/structural-flyweight.md) — LOW-MEDIUM (cuts memory when spawning millions of similar objects (game particles, map tiles, glyphs) by sharing one immutable intrinsic-state object via a cache and passing variable extrinsic state per call, plus `__slots__` to drop the per-instance `__dict__`)
   - 2.7 [Use Proxy to Insert a Substitute Controlling Access to an Object](references/structural-proxy.md) — MEDIUM-HIGH (enables lazy loading, access control, caching, and logging without touching the real subject or duplicating that logic at each call site, preserves the original interface so callers stay unchanged)
3. [Behavioral Patterns](references/_sections.md#3-behavioral-patterns) — **HIGH**
   - 3.1 [Use Chain of Responsibility to Pass Requests Through Handlers](references/behavioral-chain-of-responsibility.md) — MEDIUM-HIGH (replaces hardcoded validation/auth/parsing cascades with a composable list of handlers, enables reordering or inserting handlers without editing the others, eliminates deeply nested if/else that obscures pipeline intent)
   - 3.2 [Use Command to Turn Requests into Stand-Alone Objects](references/behavioral-command.md) — HIGH (enables undo/redo, queueing, and macro recording by reifying requests as callables or small command objects, decouples the invoker (button, shortcut) from the receiver (business logic), eliminates duplicated invocation logic across UI surfaces)
   - 3.3 [Use Iterator to Traverse Collections Without Exposing Their Internals](references/behavioral-iterator.md) — HIGH (hides a collection's representation behind the iterator protocol (list, tree, graph, stream all look the same to `for`), enables multiple independent traversals, eliminates duplicated traversal code across the app)
   - 3.4 [Use Mediator to Replace Many-to-Many Coupling with a Hub](references/behavioral-mediator.md) — MEDIUM (reduces N x N component dependencies to N x 1 by routing all interaction through one mediator, makes components reusable since they no longer reference each other directly)
   - 3.5 [Use Memento to Snapshot State Without Breaking Encapsulation](references/behavioral-memento.md) — LOW-MEDIUM (captures restorable snapshots of an object's state through a narrow object so a caretaker (history, transaction log) can store them without seeing private fields, preserves encapsulation that exposing setters would break)
   - 3.6 [Use Observer to Broadcast State Changes to Many Subscribers](references/behavioral-observer.md) — CRITICAL (enables one-to-many notification of state changes without the publisher knowing its subscribers — the foundation of event systems, reactive UI, pub/sub, and dataflow)
   - 3.7 [Use State to Alter Behavior When Internal State Changes](references/behavioral-state.md) — MEDIUM-HIGH (replaces sprawling `if self.status == ...` blocks in every method with polymorphic state objects, eliminates duplicated state checks across methods, makes adding a state one new class instead of editing every method)
   - 3.8 [Use Strategy to Make Algorithms Interchangeable at Runtime](references/behavioral-strategy.md) — HIGH (eliminates `if mode == "a": ... elif mode == "b": ...` algorithm-selection conditionals scattered through business code, enables runtime swapping of algorithm variants, isolates each algorithm as an independently testable function)
   - 3.9 [Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps](references/behavioral-template-method.md) — MEDIUM (eliminates duplicated algorithm scaffolding across sibling classes by hoisting the shared sequence into a base method, lets subclasses override only the steps that vary, removes client conditionals that switch on subtype)
   - 3.10 [Use Visitor to Add Operations to Class Hierarchies Without Modifying Them](references/behavioral-visitor.md) — LOW-MEDIUM (enables adding operations (export, validate, render) across a closed object hierarchy by writing one `@singledispatch` function instead of editing every node class, isolates each operation in one place rather than scattering it across the hierarchy)

---

## References

1. [https://refactoring.guru/design-patterns/catalog](https://refactoring.guru/design-patterns/catalog)
2. [https://refactoring.guru/design-patterns/python](https://refactoring.guru/design-patterns/python)
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