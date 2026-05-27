# TypeScript Functional Patterns

**Version 0.3.0**  
MDN / TC39 / Mostly Adequate Guide  
May 2026

---

## Abstract

Implementation guide for the functional patterns that supersede or supplement Gang of Four classes in idiomatic TypeScript: higher-order functions, lambdas-as-arguments, pipelines, function composition, stream methods (map/filter/flatMap/reduce), closures-as-data, and lambda placement (module scope vs nested vs inline). Each rule names the GoF or imperative anti-pattern it replaces and states when the class form still wins (serialization, runtime registry, typed inter-pattern relations, cross-cutting state). Sibling to implementation-design-patterns — read this skill when the answer in TypeScript is a function, not a class.

---

## Table of Contents

1. [Creational alternatives](references/_sections.md#1-creational-alternatives) — **HIGH**
   - 1.1 [Export a module-scope constant or lazy memo instead of a Singleton class](references/create-module-scope-over-singleton.md)
   - 1.2 [Return a tagged object from a factory function instead of a Factory class hierarchy](references/create-factory-function-over-factory-classes.md)
   - 1.3 [Use an object literal with optional fields, or a fluent immutable builder, instead of a mutable Builder class](references/create-fluent-immutable-builder.md)
2. [Higher-order functions](references/_sections.md#2-higher-order-functions) — **HIGH**
   - 2.1 [Pass a lambda instead of defining a Strategy class when variation is one function](references/hof-lambda-as-strategy.md)
3. [Pipelines and composition](references/_sections.md#3-pipelines-and-composition) — **HIGH**
   - 3.1 [Compose a request pipeline as pipe(handler, handler, handler) instead of linked Handler classes](references/pipe-pipeline-over-chain-of-responsibility.md)
   - 3.2 [Compose wrappers as compose(withCache, withLogging, withAuth)(handler) instead of Decorator classes](references/pipe-compose-over-decorator.md)
4. [Stream methods](references/_sections.md#4-stream-methods) — **HIGH**
   - 4.1 [Collapse .filter().map().filter() chains into a single pass when the input is large or the chain is hot](references/stream-prefer-single-pass-over-chained-passes.md)
   - 4.2 [Use flatMap for one-to-many transforms instead of nested loops or map().reduce(concat)](references/stream-flatmap-over-nested-loops.md)
   - 4.3 [Use generators or Iterator helpers for early-exit over large or infinite sequences](references/stream-lazy-iteration-for-large-or-infinite.md)
   - 4.4 [Use reduce / Object.groupBy / Map.groupBy for aggregation instead of imperative accumulators](references/stream-reduce-over-imperative-accumulation.md)
5. [Wrappers](references/_sections.md#5-wrappers) — **HIGH**
   - 5.1 [Translate or simplify an interface with a wrapper function instead of an Adapter or Facade class](references/wrap-function-over-adapter-and-facade.md)
   - 5.2 [Use the native Proxy primitive or an HOF wrapper instead of a Proxy class](references/wrap-proxy-native-or-hof.md)
6. [Caching and sharing](references/_sections.md#6-caching-and-sharing) — **HIGH**
   - 6.1 [Cache shared values with a WeakMap or Map plus a factory function, not a Flyweight class](references/cache-weakmap-over-flyweight.md)
7. [Pattern matching on tagged unions](references/_sections.md#7-pattern-matching-on-tagged-unions) — **HIGH**
   - 7.1 [Model State, Visitor, and Composite as a discriminated union with an exhaustive match](references/match-tagged-union-over-state-visitor-composite.md)
8. [Signals and event emitters](references/_sections.md#8-signals-and-event-emitters) — **HIGH**
   - 8.1 [Wire many-to-many or one-to-many communication with an event emitter or signal, not a Mediator or Observer class](references/signal-event-emitter-over-mediator-and-observer.md)
9. [Placement and identity](references/_sections.md#9-placement-and-identity) — **HIGH**
   - 9.1 [Place pure transformer lambdas at module scope, not inside a component or hook](references/place-module-scope-pure-transformers.md)
10. [Closures and data-carrying functions](references/_sections.md#10-closures-and-data-carrying-functions) — **MEDIUM**
   - 10.1 [Store a closure in the queue instead of a Command class when nothing inspects or serializes it](references/closure-as-command.md)

---

## References

1. [https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
2. [https://github.com/tc39/proposal-iterator-helpers](https://github.com/tc39/proposal-iterator-helpers)
3. [https://mostly-adequate.gitbook.io/mostly-adequate-guide/](https://mostly-adequate.gitbook.io/mostly-adequate-guide/)
4. [https://github.com/tc39/proposal-pipeline-operator](https://github.com/tc39/proposal-pipeline-operator)
5. [https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |