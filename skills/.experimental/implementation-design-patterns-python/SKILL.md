---
name: implementation-design-patterns-python
description: Implementation guide for the 22 Gang of Four design patterns in idiomatic modern Python (3.10+), distilled from refactoring.guru. Use when writing, refactoring, or reviewing Python with a pattern-shaped problem — class-explosion from inheritance, conditionals switching on type, tight coupling to concrete classes, tree-shaped models, runtime algorithm selection, undo/redo, state-dependent behavior, or hiding subsystem complexity. Each entry leads with the Pythonic form (functions, dataclasses, Protocol, singledispatch, match, generators, copy/replace) and falls back to the class-based GoF structure only when identity, state, or dispatch require it. Includes intent, applicability (when to use AND when NOT to), a runnable example, steps, pros/cons, and relations. Trigger even when no pattern is named — cues like "too many constructor params," "giant if/elif," "swap behavior at runtime," "need undo," or "walk a tree" are pattern-shaped. Covers all 5 Creational, 7 Structural, and 10 Behavioral GoF patterns.
metadata:
  internal: true
---
# Python Design Patterns Best Practices (Refactoring Guru)

Implementation reference for the 22 Gang of Four design patterns in **idiomatic modern Python (3.10+)**, distilled from refactoring.guru. Each of the **22 pattern files across 3 categories** captures intent, problem, solution, applicability (when to use AND when NOT to), a runnable Python example with output, implementation steps, pros/cons, and relations to sibling patterns.

This is the **Pythonic-first** companion to the TypeScript design-patterns skill. Most GoF patterns shrink to a language feature in Python — a function, a generator, a dataclass, `functools.singledispatch`, a `match` statement. Every entry leads with that idiomatic form and keeps the class-based GoF structure only where identity, stored state, runtime registration, or polymorphic dispatch genuinely earn it.

The patterns are a *vocabulary for structural decisions*, not a prescription. Reach for one only when its applicability criteria match — every entry includes a **When NOT to Use** section to guard against over-engineering, which is the more common failure with this catalog in Python.

## When to Apply

- A constructor has grown to 10+ parameters (telescoping-constructor smell) or subclasses exist only to bake in parameter combinations
- A method branches on `kind`/`type`/`mode`/`status` to pick an algorithm or behavior — a `match` or `if/elif` ladder that grows with each variant
- Integrating an incompatible third-party API, library, or legacy class whose method names don't match your code
- Modeling a tree-shaped domain (file systems, ASTs, UI trees, org charts) where leaves and branches must be treated uniformly
- Adding cross-cutting behavior at runtime — logging, caching, access control, compression — without subclassing
- Selecting an algorithm or behavior variant at runtime from config, user input, or environment
- Implementing undo/redo, history snapshots, transactional rollback, or queueing/scheduling of operations
- Coordinating many objects whose direct mutual references have become tangled — a hub that brokers communication
- Notifying many subscribers when something changes — event systems, reactive data flows
- Reviewing code that smells like a pattern is implicit (a giant `if isinstance(...)`, parallel class hierarchies, copy-pasted algorithm skeletons) — make it explicit, or collapse it to a Python idiom

## Rule Categories

| # | Category | Impact | Patterns | When to reach for this group |
|---|----------|--------|----------|------------------------------|
| 1 | **Creational** | HIGH | 5 | Object construction is non-trivial, varies by configuration, or risks tight coupling to concrete classes |
| 2 | **Structural** | HIGH | 7 | Composing classes/objects into larger structures while keeping parts substitutable |
| 3 | **Behavioral** | HIGH | 10 | Distributing responsibility and defining how objects collaborate at runtime |

## How to Use

1. **Recognize the shape.** Read the **Quick Reference** below and identify which pattern's intent matches your problem. Most pattern-shaped problems sound like one of the listed phrases.
2. **Read the pattern reference.** Open `references/{category}-{pattern}.md`. Confirm intent, then read **Applicability** and **When NOT to Use** before adopting.
3. **Lead with the idiom.** Each "Correct" example shows the Pythonic form first. Adopt it unless you need the class-based structure shown in the **Alternative** block.
4. **Adapt to your domain.** The examples use small realistic domains (transports, route planners, document trees). Rename to your terms before merging.
5. **Check the relations.** Each entry ends with **Related Patterns** — siblings worth considering for the same problem.

## Quick Reference

### 1. Creational Patterns (object instantiation)

- [`creational-factory-method`](references/creational-factory-method.md) — Resolve a concrete class through a registry/dispatch dict. *"I want to pick a class by config/string key without an if/elif ladder."* — **HIGH**
- [`creational-abstract-factory`](references/creational-abstract-factory.md) — Produce families of related objects that must match. *"Switching one flag must swap a whole coordinated set (button + checkbox)."* — **MEDIUM-HIGH**
- [`creational-builder`](references/creational-builder.md) — Construct complex objects step by step — in Python a keyword-only dataclass first. *"My constructor has 10+ params, or I need staged assembly."* — **HIGH**
- [`creational-prototype`](references/creational-prototype.md) — Clone via `copy.deepcopy` / `dataclasses.replace`. *"I need another one just like this, with one value changed."* — **MEDIUM**
- [`creational-singleton`](references/creational-singleton.md) — One shared instance via a module global or `functools.cache`. *"I need exactly one config/registry/pool, kept testable."* — **MEDIUM**

### 2. Structural Patterns (composition)

- [`structural-adapter`](references/structural-adapter.md) — Wrap a class so its interface matches what callers expect. *"This library's method names don't match mine and I can't edit it."* — **HIGH**
- [`structural-bridge`](references/structural-bridge.md) — Split abstraction from implementation via composition + `Protocol`. *"Two orthogonal axes and the subclass count is exploding."* — **MEDIUM**
- [`structural-composite`](references/structural-composite.md) — Treat leaves and trees uniformly via a shared `Protocol` + recursion. *"I have a tree and want one interface for items and groups."* — **HIGH**
- [`structural-decorator`](references/structural-decorator.md) — Stack wrappers (or use `@decorator`) to add behavior at runtime. *"I want to layer logging + caching + compression in any order."* — **HIGH**
- [`structural-facade`](references/structural-facade.md) — Expose one function/module over a complex subsystem. *"I just want `convert(file, fmt)`, not the codec/bitrate dance."* — **HIGH**
- [`structural-flyweight`](references/structural-flyweight.md) — Share immutable state via a cached factory + `__slots__`. *"Millions of objects, only a few distinct payloads — out of RAM."* — **LOW-MEDIUM**
- [`structural-proxy`](references/structural-proxy.md) — Stand in via `__getattr__` / `cached_property` to control access. *"I need lazy loading / auth / caching without touching the real object."* — **MEDIUM-HIGH**

### 3. Behavioral Patterns (collaboration)

- [`behavioral-chain-of-responsibility`](references/behavioral-chain-of-responsibility.md) — Run a request through an ordered list of handlers. *"A pipeline of auth/validate/authorize checks I want to reorder."* — **MEDIUM-HIGH**
- [`behavioral-command`](references/behavioral-command.md) — Reify a request as a callable/closure with optional undo. *"I need undo/redo, queueing, or one action shared across UI surfaces."* — **HIGH**
- [`behavioral-iterator`](references/behavioral-iterator.md) — Traverse via `__iter__`/generators without exposing internals. *"I want `for x in my_structure` to just work."* — **HIGH**
- [`behavioral-mediator`](references/behavioral-mediator.md) — Route component interaction through one hub. *"My widgets all reference each other and nothing is reusable."* — **MEDIUM**
- [`behavioral-memento`](references/behavioral-memento.md) — Snapshot/restore state via a frozen dataclass. *"I need undo/rollback without exposing private fields."* — **LOW-MEDIUM**
- [`behavioral-observer`](references/behavioral-observer.md) — Notify subscriber callbacks on change (often a `property` setter). *"Many objects must react when one value changes — events, reactive UI."* — **CRITICAL**
- [`behavioral-state`](references/behavioral-state.md) — Delegate to polymorphic state objects (or an enum + dispatch). *"My class is a state machine with `if status ==` in every method."* — **MEDIUM-HIGH**
- [`behavioral-strategy`](references/behavioral-strategy.md) — Pass an algorithm as a `Callable` and swap it at runtime. *"Multiple algorithms (sort/route/pay) picked without conditionals."* — **HIGH**
- [`behavioral-template-method`](references/behavioral-template-method.md) — Fix a skeleton in an ABC; subclasses override steps. *"Several classes share an algorithm with a couple of varying steps."* — **MEDIUM**
- [`behavioral-visitor`](references/behavioral-visitor.md) — Add operations via `functools.singledispatch` / `match`. *"I need 5 operations across an AST without editing the node classes."* — **LOW-MEDIUM**

## How to Choose Between Similar Patterns

Several patterns share a shape but solve different problems. Read each pattern's **Related Patterns** section, then apply these distinctions:

- **Adapter vs. Facade vs. Proxy vs. Decorator** — all four wrap a target. *Adapter* changes the interface. *Facade* simplifies a subsystem. *Proxy* keeps the interface and controls access/lifecycle. *Decorator* keeps the interface and adds behavior recursively.
- **Strategy vs. State** — both delegate to a swapped object. *Strategy* variants are independent functions the caller picks. *State* objects know each other and trigger transitions on the context.
- **Strategy vs. Template Method** — both vary parts of an algorithm. *Strategy* uses composition — a `Callable` swapped at runtime. *Template Method* uses inheritance — an ABC skeleton fixed at definition time.
- **Factory Method vs. Abstract Factory vs. Builder** — *Factory Method* resolves one product (a registry/`@classmethod`). *Abstract Factory* returns a family of matching products. *Builder* assembles one complex product (a keyword-only dataclass, or a fluent builder for staged construction).
- **Composite vs. Decorator** — both wrap children recursively. *Composite* aggregates child results. *Decorator* adds one responsibility and passes through.
- **Chain of Responsibility vs. Command vs. Mediator vs. Observer** — all connect senders and receivers. *CoR* passes a request along a list of handlers (and may stop early). *Command* makes the request a first-class callable. *Mediator* centralizes many-to-many communication. *Observer* establishes one-publisher-to-many-subscribers notification.
- **Visitor: `singledispatch` vs. `match` vs. methods** — use `functools.singledispatch` to add operations over a closed type set without editing the classes; use `match` when you'd rather keep all cases in one exhaustive function; use plain methods when there's one operation and the type set is small.

## References

1. [Refactoring Guru — Design Patterns Catalog](https://refactoring.guru/design-patterns/catalog)
2. [Refactoring Guru — Python Examples](https://refactoring.guru/design-patterns/python)
3. [Refactoring Guru — Creational Patterns](https://refactoring.guru/design-patterns/creational-patterns)
4. [Refactoring Guru — Structural Patterns](https://refactoring.guru/design-patterns/structural-patterns)
5. [Refactoring Guru — Behavioral Patterns](https://refactoring.guru/design-patterns/behavioral-patterns)
