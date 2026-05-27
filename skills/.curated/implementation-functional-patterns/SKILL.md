---
name: implementation-functional-patterns
description: TypeScript's functional answers to the 22 Gang of Four classes — factory functions (Factory Method, Abstract Factory, Prototype, Memento), module-scope singletons, fluent immutable builders, wrapper functions (Adapter, Facade), native Proxy, WeakMap caches (Flyweight), discriminated unions with exhaustive match (State, Visitor, Composite), event emitters and signals (Mediator, Observer), pipelines and composition (CoR, Decorator), stream methods (Iterator), closures-as-commands, higher-order strategies, lambda placement. Use when reviewing TypeScript that has a class-shaped problem the GoF catalog solves with a hierarchy but where idiomatic TS reaches for a function, a tagged union, or a data structure. Each rule names the GoF pattern(s) it replaces and when the class form still wins. Trigger on "factory class", "singleton getInstance", "state machine class", "observer pattern", "AST visitor", "where do I put this lambda". Sibling to implementation-design-patterns.
---

# TypeScript Functional Patterns

Implementation reference for the functional shapes that supersede the Gang of Four catalog in idiomatic TypeScript. Sibling to [`implementation-design-patterns`](../implementation-design-patterns/SKILL.md): read that one when the answer is a class, this one when the answer is a function, a tagged union, or a small data structure.

TypeScript has first-class functions, discriminated unions, structural typing, and zero ceremony around closures. That means the 22 GoF patterns — written in the catalog as class hierarchies because the source material targets Java/C# — collapse to far fewer functional shapes in real TS code. Several patterns share a functional answer: tagged unions cover State, Visitor, and Composite; factory functions cover Factory Method, Abstract Factory, Prototype, and Memento; event emitters cover Mediator and Observer; wrapper functions cover Adapter and Facade. This skill names those collapses, the placement rules they imply, and the performance trade-offs.

## When to Apply

- Refactoring a Factory class hierarchy, an `AbstractFactory` returning families of products, or a class with `clone()` / Memento save-restore
- Refactoring a Singleton class with `private constructor` + `static getInstance`
- Refactoring a mutable Builder class for a configuration object with many optional fields
- Refactoring a Strategy / Template Method / Bridge class hierarchy where variation is a single method
- Replacing a Chain of Responsibility class chain or Decorator wrapper-class stack
- Replacing a custom Iterator class with stream methods, generators, or lazy iterator helpers
- Replacing a Command class with a closure stored in a queue (when undo/serialization is not required)
- Replacing an Adapter / Facade class that exists only to forward calls or hide subsystem orchestration
- Replacing a Proxy class with native JS `Proxy` (for transparent interception) or an HOF wrapper (for selective wrapping)
- Replacing a Flyweight factory class with a `Map`/`WeakMap` cache + factory function
- Replacing a State / Visitor / Composite class hierarchy with a discriminated union + exhaustive `match` function
- Replacing a Mediator / Observer class with an event emitter or reactive signal
- Reviewing TSX where lambdas appear inline in JSX, hook deps, or `memo`'d child props — placement controls identity
- Recognizing imperative `for` loops with mutated accumulators that would read more honestly as `reduce`, `Object.groupBy`, or `flatMap`

## Rule Categories

| # | Category | Impact | Rules | Theme |
|---|----------|--------|-------|-------|
| 1 | **Creational alternatives** (`create`) | HIGH | 3 | Factory functions, module-scope singletons, fluent immutable builders |
| 2 | **Higher-order functions** (`hof`) | HIGH | 1 | Pass a function instead of a class |
| 3 | **Pipelines & composition** (`pipe`) | HIGH | 2 | Compose small functions: `pipe` (data flow), `compose` (wrapper layering) |
| 4 | **Stream methods** (`stream`) | HIGH | 4 | `map`/`filter`/`flatMap`/`reduce`, lazy iteration, single-pass chains |
| 5 | **Wrappers** (`wrap`) | HIGH | 2 | Wrapper functions for Adapter/Facade; native `Proxy` or HOF for Proxy |
| 6 | **Caching & sharing** (`cache`) | HIGH | 1 | `Map`/`WeakMap` + factory function over Flyweight class |
| 7 | **Pattern matching** (`match`) | HIGH | 1 | Discriminated unions + exhaustive match for State/Visitor/Composite |
| 8 | **Signals & event emitters** (`signal`) | HIGH | 1 | Event emitter / signal for Mediator/Observer |
| 9 | **Placement & identity** (`place`) | HIGH | 1 | Where the lambda lives controls behavior |
| 10 | **Closures as data** (`closure`) | MEDIUM | 1 | Functions that carry their state |

**17 rules across 10 categories, covering all 22 GoF patterns** (some patterns share a functional answer — see the GoF → Functional Map below).

## GoF → Functional Map

The full mapping from each Gang of Four pattern to its functional answer in idiomatic TS. Read this table to find the rule for a specific pattern; read the categories above to find rules by functional technique.

| GoF Group | GoF Pattern | Functional Equivalent | Rule |
|-----------|-------------|------------------------|------|
| **Creational** | Factory Method | Function returning tagged object | [`create-factory-function-over-factory-classes`](references/create-factory-function-over-factory-classes.md) |
| | Abstract Factory | Function returning record of constructors | covered by factory-function rule |
| | Builder | Object literal + `Partial<T>`, or fluent immutable | [`create-fluent-immutable-builder`](references/create-fluent-immutable-builder.md) |
| | Prototype | `structuredClone` / spread / Immer `produce` | covered by factory-function rule |
| | Singleton | Module-scope const, lazy `??=` memo | [`create-module-scope-over-singleton`](references/create-module-scope-over-singleton.md) |
| **Structural** | Adapter | Wrapper function translating shape | [`wrap-function-over-adapter-and-facade`](references/wrap-function-over-adapter-and-facade.md) |
| | Bridge | HOF parametrized by implementation | covered by [`hof-lambda-as-strategy`](references/hof-lambda-as-strategy.md) |
| | Composite | Discriminated union + recursive fn | covered by tagged-union rule |
| | Decorator | `compose(withA, withB, withC)(target)` | [`pipe-compose-over-decorator`](references/pipe-compose-over-decorator.md) |
| | Facade | Single high-level function hiding subsystem | covered by wrap-function rule |
| | Flyweight | `Map`/`WeakMap` + factory function | [`cache-weakmap-over-flyweight`](references/cache-weakmap-over-flyweight.md) |
| | Proxy | Native `Proxy` or HOF wrapper | [`wrap-proxy-native-or-hof`](references/wrap-proxy-native-or-hof.md) |
| **Behavioral** | Chain of Responsibility | `pipe(fn1, fn2)` / array fold | [`pipe-pipeline-over-chain-of-responsibility`](references/pipe-pipeline-over-chain-of-responsibility.md) |
| | Command | Closure `() => void` | [`closure-as-command`](references/closure-as-command.md) |
| | Iterator | Stream methods + generators | [`stream-flatmap-over-nested-loops`](references/stream-flatmap-over-nested-loops.md), [`stream-reduce-over-imperative-accumulation`](references/stream-reduce-over-imperative-accumulation.md), [`stream-lazy-iteration-for-large-or-infinite`](references/stream-lazy-iteration-for-large-or-infinite.md), [`stream-prefer-single-pass-over-chained-passes`](references/stream-prefer-single-pass-over-chained-passes.md) |
| | Mediator | Event emitter / signal | [`signal-event-emitter-over-mediator-and-observer`](references/signal-event-emitter-over-mediator-and-observer.md) |
| | Memento | Immutable snapshot via `structuredClone` | covered by factory-function rule |
| | Observer | Event emitter / signal / RxJS | covered by event-emitter rule |
| | State | Discriminated union + exhaustive match | [`match-tagged-union-over-state-visitor-composite`](references/match-tagged-union-over-state-visitor-composite.md) |
| | Strategy | Lambda | [`hof-lambda-as-strategy`](references/hof-lambda-as-strategy.md) |
| | Template Method | HOF taking step callback | covered by hof-lambda rule |
| | Visitor | Discriminated union + match function | covered by tagged-union rule |

## How to Use

1. **Find the pattern.** If you know which GoF pattern you'd reach for, look it up in the *GoF → Functional Map* above and read the linked rule. If you only know the symptom (loop with accumulator, class returning class, three setters), the Quick Reference below groups rules by functional technique.
2. **Read "When NOT to apply".** Every rule lists the narrow conditions where the class form still wins. The skill is a complement to the parent skill, not a repudiation — keep the class when serialization, runtime introspection, typed inter-pattern relations, cross-cutting state, framework integration, or lifecycle ownership demands it.
3. **Check identity assumptions in TSX.** If the code lives in a TSX file or runs inside a hook, also read the `place-*` rules — placement decides whether `memo`, `useEffect`, and React Compiler can do their jobs.
4. **Mind the performance.** Every rule has a `### Performance trade-offs` section quantifying time, memory, and allocation costs. Most functional forms are performance-equivalent to the class form; a few (chained streams, `flatMap`) have real constant-factor costs that matter in hot paths.

## Quick Reference

### 1. Creational alternatives

- [`create-factory-function-over-factory-classes`](references/create-factory-function-over-factory-classes.md) — Function returning a tagged object instead of a Factory class hierarchy. Covers Factory Method, Abstract Factory, Prototype, and Memento. *"I'd write `new FooFactory().create()` — but a function returning the tagged object is shorter and tree-shakes."* — **HIGH**
- [`create-module-scope-over-singleton`](references/create-module-scope-over-singleton.md) — `export const x = …` or lazy `??=` instead of `class X { private static instance; getInstance() }`. ES modules ARE singletons; the class form is anti-idiom in TS. *"I need exactly one of these — config, DB client, logger."* — **HIGH**
- [`create-fluent-immutable-builder`](references/create-fluent-immutable-builder.md) — Object literal + `Partial<T>` for simple cases; fluent immutable (each method returns a new builder) for type-state-tracked DSLs. *"My constructor has 10 parameters / my Builder class has 8 setters."* — **HIGH**

### 2. Higher-order functions

- [`hof-lambda-as-strategy`](references/hof-lambda-as-strategy.md) — Pass a comparator/predicate/transformer lambda instead of defining a Strategy class. Also covers Template Method (HOF with step callback) and Bridge (HOF parametrized by implementation). *"My Strategy interface has one method."* — **HIGH**

### 3. Pipelines & composition

- [`pipe-pipeline-over-chain-of-responsibility`](references/pipe-pipeline-over-chain-of-responsibility.md) — `pipe(validate, authorize, parse)(req)` or an array fold of handlers, instead of a linked list of `Handler` classes. *"My CoR chain handlers each do one transform and pass the result along."* — **HIGH**
- [`pipe-compose-over-decorator`](references/pipe-compose-over-decorator.md) — `compose(withLogging, withCache, withAuth)(handler)` — each wrapper is `(handler) => handler`, not a `Decorator` class. Right-to-left order reads top-down like the class stack. *"I want to add logging + caching + auth around this handler."* — **HIGH**

### 4. Stream methods

- [`stream-flatmap-over-nested-loops`](references/stream-flatmap-over-nested-loops.md) — `.flatMap` for one-to-many transforms instead of `for` + `push` or `map().reduce(concat)`. *"For each user, expand to all their orders, then collect."* — **HIGH**
- [`stream-reduce-over-imperative-accumulation`](references/stream-reduce-over-imperative-accumulation.md) — `reduce` / `Object.groupBy` / `Map.groupBy` instead of `let acc = …; for (…) acc[…] = …`. The most common functional pattern in real TS: sums, counts, indexes, histograms. *"I'm building up a total / index / grouped map in a loop."* — **HIGH**
- [`stream-lazy-iteration-for-large-or-infinite`](references/stream-lazy-iteration-for-large-or-infinite.md) — Generators or TC39 Iterator helpers (`Iterator.from(arr).filter(p).take(10).toArray()`) when only a prefix of results is needed. O(matched-needed) instead of O(n). *"First N matches from a huge or unbounded source."* — **HIGH**
- [`stream-prefer-single-pass-over-chained-passes`](references/stream-prefer-single-pass-over-chained-passes.md) — Collapse `.filter().map().filter()` into one `reduce` or `for-of` when the input is large or the chain is hot. Three passes → one; halves peak memory; 2–5× faster in measured hot paths. *"This chain runs on every request / render over thousands of items."* — **HIGH**

### 5. Wrappers

- [`wrap-function-over-adapter-and-facade`](references/wrap-function-over-adapter-and-facade.md) — Wrapper function translating one interface to another (Adapter) or hiding subsystem orchestration (Facade). *"I'd write `class XAdapter implements Y` whose every method is one-line forwarding."* — **HIGH**
- [`wrap-proxy-native-or-hof`](references/wrap-proxy-native-or-hof.md) — Native `Proxy` for transparent dynamic-key interception, HOF wrapper for selective method-level wrapping. *"I want lazy loading / access control / interception without a Proxy class."* — **HIGH**

### 6. Caching & sharing

- [`cache-weakmap-over-flyweight`](references/cache-weakmap-over-flyweight.md) — `WeakMap`/`Map` cache + factory function instead of Flyweight factory class. `WeakMap` auto-cleans when keys go out of scope. *"I'm allocating millions of similar objects with shared state."* — **HIGH**

### 7. Pattern matching

- [`match-tagged-union-over-state-visitor-composite`](references/match-tagged-union-over-state-visitor-composite.md) — Discriminated union + `switch` on tag + `assertNever` — covers State (class per state), Visitor (double dispatch), and Composite (Leaf/Branch). Probably the single highest-payoff functional pattern in TS. *"My class has a giant switch on `kind` / I have N state classes / I'd write a Visitor over my AST."* — **HIGH**

### 8. Signals & event emitters

- [`signal-event-emitter-over-mediator-and-observer`](references/signal-event-emitter-over-mediator-and-observer.md) — Event emitter (`mitt`, `EventEmitter`) or reactive signal (Solid, Preact signals, Zustand) instead of Subject/Observer classes or central Mediator class. *"Many objects need to react when one changes / form fields need to coordinate / cross-component events."* — **HIGH**

### 9. Placement & identity

- [`place-module-scope-pure-transformers`](references/place-module-scope-pure-transformers.md) — Put pure transformer lambdas at module scope (stable identity, reusable, tree-shakable). Nest them inside a function only when they capture something. *"This `(s) => s.toLowerCase()` doesn't need to be in the component body."* — **HIGH**

### 10. Closures as data

- [`closure-as-command`](references/closure-as-command.md) — Store a `() => void` closure in the queue/history/callback list instead of a Command class with `execute()`. *"I need a queue of deferred operations and never need to inspect or serialize them."* — **MEDIUM**

## How to Choose: Class vs Function

The class form (see [`implementation-design-patterns`](../implementation-design-patterns/SKILL.md)) earns its overhead when **at least one** of these is true:

- **Serialization** — Commands or Mementos that must survive a process restart or cross a wire
- **Runtime registry / introspection** — the system enumerates known strategies, displays them in a picker, or attaches metadata
- **Typed inter-pattern relations** — Visitor over an AST where node types reference each other, State machine where states reference each other, Mediator with typed roles
- **Cross-cutting state** — the "variation" carries its own configuration, lifecycle, or invariants beyond the single call
- **Stable identity for `instanceof`** — exhaustive matching on a finite set of named classes (rare; discriminated unions usually win)
- **Lifecycle ownership** — the object owns a resource (connection, file handle, disposable) and `using` / `Symbol.dispose` integration matters
- **Framework integration** — ORMs, DI containers, decorator-based libraries, RxJS class-based services expect classes

Otherwise, default to the function (or tagged union, or data structure). The class wraps the value in ceremony that earns nothing.

## References

1. [MDN — `Array.prototype`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
2. [TC39 — Iterator Helpers proposal](https://github.com/tc39/proposal-iterator-helpers)
3. [Mostly Adequate Guide to Functional Programming (Brian Lonsdorf)](https://mostly-adequate.gitbook.io/mostly-adequate-guide/)
4. [TC39 — Pipeline Operator proposal](https://github.com/tc39/proposal-pipeline-operator)
5. [MDN — Closures](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
6. [TS Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
7. [MDN — `Proxy`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy)
8. [MDN — `WeakMap`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)
9. [MDN — `structuredClone`](https://developer.mozilla.org/en-US/docs/Web/API/structuredClone)
