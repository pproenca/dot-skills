# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group pattern references.

These patterns are the functional counterparts to the Gang of Four catalog covered in [`implementation-design-patterns`](../../implementation-design-patterns/SKILL.md). In TypeScript — a language with first-class functions, structural typing, discriminated unions, and zero ceremony around closures — the idiomatic answer to many GoF shapes is a function with a lambda, a tagged union with a match, or a small data structure with a factory function, not a class hierarchy. Each rule below names the GoF pattern(s) it replaces and lists the narrow conditions under which the class form is still the right call (serialization, runtime registry, typed inter-pattern relations, cross-cutting state, framework integration, lifecycle ownership).

The 22 GoF patterns collapse to fewer rules here because several patterns share a functional answer: tagged unions replace State / Visitor / Composite; factory functions replace Factory Method / Abstract Factory / Prototype / Memento; event emitters replace Mediator / Observer; wrapper functions replace Adapter / Facade. See SKILL.md's *GoF → Functional Map* table for the full mapping.

---

## 1. Creational alternatives (create)

**Impact:** HIGH
**Description:** Three rules replacing GoF's Creational catalog: factory functions returning tagged objects (Factory Method, Abstract Factory, Prototype, Memento), module-scope constants and lazy memos (Singleton), and fluent immutable or object-literal builders (Builder). Apply on any "produce an object" code that defaults to class hierarchies.

## 2. Higher-order functions (hof)

**Impact:** HIGH
**Description:** The central move of functional design: pass a function instead of a class. Replaces Strategy, Template Method, and Bridge (HOF parametrized by implementation). Apply whenever variation is a single algorithm step and the variant has no internal state of its own.

## 3. Pipelines and composition (pipe)

**Impact:** HIGH
**Description:** Composing small functions into bigger ones: `pipe` for forward data flow, `compose` for wrapper layering. Replaces Chain of Responsibility (linked handler classes) and Decorator (wrapper classes). Apply when each step takes the previous step's output and produces the next input, or when several cross-cutting concerns wrap the same operation.

## 4. Stream methods (stream)

**Impact:** HIGH
**Description:** `map`, `filter`, `flatMap`, `reduce`, lazy iterators, and the big-O of how they chain. Replaces Iterator-as-a-class and most imperative `for` loops with an accumulator. Apply when transforming or aggregating collections; reach for lazy iteration (generators / TC39 Iterator helpers) when the upstream is large, infinite, or expensive; collapse to a single pass when the chain is hot or the data is large.

## 5. Wrappers (wrap)

**Impact:** HIGH
**Description:** Two rules collapsing Adapter, Facade, and Proxy: a wrapper function for interface translation or subsystem simplification (Adapter, Facade), and native `Proxy` or HOF wrapper for transparent / selective interception (Proxy). Apply whenever you would write a class that exists only to forward calls.

## 6. Caching and sharing (cache)

**Impact:** HIGH
**Description:** Memoization with `Map` or `WeakMap` plus a factory function — the functional answer to Flyweight (shared intrinsic state across many objects) and to general memoization needs. Apply when you'd otherwise allocate many similar objects with shared state, or when an expensive keyed computation is repeated.

## 7. Pattern matching on tagged unions (match)

**Impact:** HIGH
**Description:** Discriminated unions plus exhaustive `match` functions (with `assertNever`) — the single highest-payoff TS functional pattern. Replaces State (class per state), Visitor (double dispatch over class hierarchies), and Composite (Leaf/Branch class trees). Apply on any code that switches on a type / kind / status field, walks a recursive structure, or implements a state machine.

## 8. Signals and event emitters (signal)

**Impact:** HIGH
**Description:** Event emitters and reactive signals as the functional answer to Mediator (central hub for many-to-many) and Observer (one publisher → many subscribers). Apply when wiring cross-component communication, reactive state updates, pub-sub, or event-driven workflows.

## 9. Placement and identity (place)

**Impact:** HIGH
**Description:** *Where* you put the lambda: module scope, function scope, or inline in JSX / a hook deps array. Placement controls referential identity (which determines memo/effect-dep behavior), closure capture (which determines correctness), tree-shakability, and per-render allocation cost. Apply on every function-definition decision in a TSX or hot-path file.

## 10. Closures and data-carrying functions (closure)

**Impact:** MEDIUM
**Description:** Using closures to carry state with behavior — the lightweight alternative to Command and small object-with-one-method classes. Apply when the captured state is purely local and never needs to be serialized, inspected, or composed across instances.
