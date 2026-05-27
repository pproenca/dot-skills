# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group pattern references.

These patterns are the functional counterparts to the Gang of Four catalog covered in [`implementation-design-patterns`](../../implementation-design-patterns/SKILL.md). In TypeScript — a language with first-class functions, structural typing, and zero ceremony around closures — the idiomatic answer to many GoF shapes is a higher-order function with a lambda, not a class hierarchy. Each rule below names the class-based pattern it replaces and states the narrow conditions under which the class form is still the right call (serialization, runtime registry, typed inter-pattern relations, cross-cutting state).

---

## 1. Higher-order functions (hof)

**Impact:** HIGH
**Description:** The central move of functional design: pass a function instead of a class. Replaces Strategy, Template Method, and most "interface with one method" abstractions. Apply whenever variation is a single algorithm step and the variant has no internal state of its own.

## 2. Pipelines and composition (pipe)

**Impact:** HIGH
**Description:** Composing small functions into bigger ones: `pipe` for forward data flow, `compose` for wrapper layering. Replaces Chain of Responsibility (linked handler classes) and Decorator (wrapper classes). Apply when each step takes the previous step's output and produces the next input, or when several cross-cutting concerns wrap the same operation.

## 3. Stream methods (stream)

**Impact:** HIGH
**Description:** `map`, `filter`, `flatMap`, `reduce`, lazy iterators, and the big-O of how they chain. Replaces Iterator-as-a-class and most imperative `for` loops with an accumulator. Apply when transforming or aggregating collections; reach for lazy iteration (generators / TC39 Iterator helpers) when the upstream is large, infinite, or expensive; collapse to a single pass when the chain is hot or the data is large.

## 4. Placement and identity (place)

**Impact:** HIGH
**Description:** *Where* you put the lambda: module scope, function scope, or inline in JSX / a hook deps array. Placement controls referential identity (which determines memo/effect-dep behavior), closure capture (which determines correctness), tree-shakability, and per-render allocation cost. Apply on every function-definition decision in a TSX or hot-path file.

## 5. Closures and data-carrying functions (closure)

**Impact:** MEDIUM
**Description:** Using closures to carry state with behavior — the lightweight alternative to Command, Memento, and small object-with-one-method classes. Apply when the captured state is purely local and never needs to be serialized, inspected, or composed across instances.
