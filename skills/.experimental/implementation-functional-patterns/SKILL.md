---
name: implementation-functional-patterns
description: TypeScript's functional patterns that supersede Gang of Four classes — higher-order functions, lambdas-as-arguments, pipelines (pipe/compose), stream methods (map/filter/flatMap/reduce), closures-as-data, and lambda placement (module scope vs nested vs inline in JSX/hook deps). Use when writing or reviewing TypeScript that has a class-shaped problem the GoF catalog would solve with a hierarchy, but where idiomatic TS reaches for a function — passing a comparator to sort, a handler array to a pipeline, a transformer chain to a collection, or a closure to a queue. Each rule names the GoF pattern (Strategy, Iterator, Command, Chain of Responsibility, Decorator, Template Method) it replaces and states when the class form still wins. Trigger on cues like "map/filter/flatMap to transform", "pipeline of validators", "pass a function instead of subclassing", "where do I put this lambda", "inline arrow in JSX". Sibling to implementation-design-patterns.
---

# TypeScript Functional Patterns

Implementation reference for the functional shapes that supersede or supplement Gang of Four classes in idiomatic TypeScript. Sibling to [`implementation-design-patterns`](../implementation-design-patterns/SKILL.md): read that one when the answer is a class, this one when the answer is a function.

TypeScript has first-class functions, structural typing, and zero ceremony around closures. That means many GoF patterns — written in the catalog as class hierarchies because the source material targets Java/C# — collapse to a higher-order function with a lambda in real TS code. This skill names those collapses and the placement rules they imply.

## When to Apply

- Refactoring a Strategy class that has a single varying method — the lambda equivalent is one line of call-site code
- Replacing a Chain of Responsibility class hierarchy with a `pipe(...)` of small functions or an array fold
- Replacing a Decorator wrapper class with function composition (`compose(withCache, withLogging, withAuth)(fn)`)
- Replacing a custom Iterator class with `map`/`filter`/`flatMap`/`reduce` or a generator
- Replacing a Command class with a closure stored in a queue (when undo/serialization/inspection is not required)
- Replacing a Template Method base class with an HOF that takes the step as a callback
- Reviewing TSX where lambdas appear inline in JSX, hook dependency arrays, or `memo`'d child props — placement controls identity, which controls re-render and effect-fire behavior
- Reviewing TSX where a transformer is defined inside a component but doesn't capture component-local state — it belongs at module scope
- Recognizing imperative `for` loops with a mutated accumulator that would read more honestly as `reduce` (or stay as a loop if the per-iteration logic is meaningfully side-effecting)

## Rule Categories

| # | Category | Impact | Theme |
|---|----------|--------|-------|
| 1 | **Higher-order functions** (`hof`) | HIGH | Pass a function instead of a class |
| 2 | **Pipelines & composition** (`pipe`) | HIGH | Compose small functions into bigger ones |
| 3 | **Stream methods** (`stream`) | HIGH | `map`/`filter`/`flatMap`/`reduce` over imperative loops |
| 4 | **Placement & identity** (`place`) | HIGH | Where the lambda lives controls behavior |
| 5 | **Closures as data** (`closure`) | MEDIUM | Functions that carry their state |

## How to Use

1. **Recognize the shape.** Read the Quick Reference and identify which GoF pattern (or imperative anti-pattern) you would have reached for. The corresponding functional rule is named alongside.
2. **Read the rule.** Open `references/{category}-{rule}.md`. Confirm the "When NOT to apply" section — every rule lists the narrow conditions where the class/imperative form is still the right call.
3. **Check identity assumptions.** If the code lives in a TSX file or runs inside a hook, also read the `place-*` rules — placement decides whether `memo`, `useEffect`, and React Compiler can do their jobs.

## Quick Reference

### 1. Higher-order functions

- [`hof-lambda-as-strategy`](references/hof-lambda-as-strategy.md) — Pass a comparator/predicate/transformer lambda instead of defining a Strategy class. *"My Strategy interface has one method."* — **HIGH**

### 2. Pipelines & composition

- [`pipe-pipeline-over-chain-of-responsibility`](references/pipe-pipeline-over-chain-of-responsibility.md) — `pipe(validate, authorize, parse)(req)` or an array fold of handlers, instead of a linked list of `Handler` classes. *"My CoR chain handlers each do one transform and pass the result along."* — **HIGH**

### 3. Stream methods

- [`stream-flatmap-over-nested-loops`](references/stream-flatmap-over-nested-loops.md) — `.flatMap` for one-to-many transforms instead of `for` + `push` or `map().reduce(concat)`. *"For each user, expand to all their orders, then collect."* — **HIGH**

### 4. Placement & identity

- [`place-module-scope-pure-transformers`](references/place-module-scope-pure-transformers.md) — Put pure transformer lambdas at module scope (stable identity, reusable, tree-shakable). Nest them inside a function only when they capture something. *"This `(s) => s.toLowerCase()` doesn't need to be in the component body."* — **HIGH**

### 5. Closures as data

- [`closure-as-command`](references/closure-as-command.md) — Store a `() => void` closure in the queue/history/callback list instead of a Command class with `execute()`. *"I need a queue of deferred operations and never need to inspect or serialize them."* — **MEDIUM**

## How to Choose: Class vs Function

The class form (see [`implementation-design-patterns`](../implementation-design-patterns/SKILL.md)) earns its overhead when **at least one** of these is true:

- **Serialization** — Commands or Mementos that must survive a process restart or cross a wire
- **Runtime registry / introspection** — the system enumerates known strategies, displays them in a picker, or attaches metadata
- **Typed inter-pattern relations** — Visitor over an AST, State machine where states reference each other, Mediator with typed roles
- **Cross-cutting state** — the "variation" carries its own configuration, lifecycle, or invariants beyond the single algorithm call
- **Stable identity for `instanceof` / discriminated unions** — exhaustive matching on a finite set of classes

Otherwise, default to the function. The class wraps the function in ceremony that earns nothing.

## References

1. [MDN — `Array.prototype`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
2. [TC39 — Iterator Helpers proposal](https://github.com/tc39/proposal-iterator-helpers)
3. [Mostly Adequate Guide to Functional Programming (Brian Lonsdorf)](https://mostly-adequate.gitbook.io/mostly-adequate-guide/)
4. [TC39 — Pipeline Operator proposal](https://github.com/tc39/proposal-pipeline-operator)
5. [MDN — Closures](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
