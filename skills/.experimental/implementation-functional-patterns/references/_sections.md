# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group pattern references.

These patterns are the functional counterparts to the Gang of Four catalog covered in [`implementation-design-patterns`](../../implementation-design-patterns/SKILL.md). In TypeScript — a language with first-class functions, structural typing, and zero ceremony around closures — the idiomatic answer to many GoF shapes is a higher-order function with a lambda, not a class hierarchy. Each rule below names the class-based pattern it replaces and states the narrow conditions under which the class form is still the right call (serialization, runtime registry, typed inter-pattern relations, cross-cutting state).

---

## 1. Higher-order functions (hof)

**Impact:** HIGH
**Description:** Three rules for the central move of functional design: pass a function instead of a class. Replaces Strategy, Template Method, and most "interface with one method" abstractions. Apply whenever variation is a single algorithm step and the variant has no internal state of its own.

## 2. Pipelines and composition (pipe)

**Impact:** HIGH
**Description:** Three rules for composing small functions into bigger ones: `pipe`, `compose`, and method chains. Replaces Chain of Responsibility (linked handler classes), Decorator (wrapper classes), and the imperative "build up a result through a sequence of mutations" anti-pattern. Apply when each step takes the previous step's output and produces the next input.

## 3. Stream methods (stream)

**Impact:** HIGH
**Description:** Four rules on `map`, `filter`, `flatMap`, `reduce`, and generator-based lazy iteration. Replaces Iterator-as-a-class and most imperative `for` loops with an accumulator. Apply when transforming or aggregating collections; reach for generators when the upstream is infinite or expensive.

## 4. Placement and identity (place)

**Impact:** HIGH
**Description:** Three rules on *where* you put the lambda: module scope, function scope, or inline in JSX / a hook deps array. Placement controls referential identity (which determines memo/effect-dep behavior), closure capture (which determines correctness), and tree-shakability. Apply on every function definition decision in a TSX or hot-path file.

## 5. Closures and data-carrying functions (closure)

**Impact:** MEDIUM
**Description:** Two rules on using closures to carry state with behavior — the lightweight alternative to Command, Memento, and small object-with-one-method classes. Apply when the captured state is purely local and never needs to be serialized, inspected, or composed across instances.
