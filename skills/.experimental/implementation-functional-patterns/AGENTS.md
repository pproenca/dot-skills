# TypeScript Functional Patterns

**Version 0.1.0**  
MDN / TC39 / Mostly Adequate Guide  
May 2026

---

## Abstract

Implementation guide for the functional patterns that supersede or supplement Gang of Four classes in idiomatic TypeScript: higher-order functions, lambdas-as-arguments, pipelines, function composition, stream methods (map/filter/flatMap/reduce), closures-as-data, and lambda placement (module scope vs nested vs inline). Each rule names the GoF or imperative anti-pattern it replaces and states when the class form still wins (serialization, runtime registry, typed inter-pattern relations, cross-cutting state). Sibling to implementation-design-patterns — read this skill when the answer in TypeScript is a function, not a class.

---

## Table of Contents

1. [Higher-order functions](references/_sections.md#1-higher-order-functions) — **HIGH**
   - 1.1 [Pass a lambda instead of defining a Strategy class when variation is one function](references/hof-lambda-as-strategy.md)
2. [Pipelines and composition](references/_sections.md#2-pipelines-and-composition) — **HIGH**
   - 2.1 [Compose a request pipeline as pipe(handler, handler, handler) instead of linked Handler classes](references/pipe-pipeline-over-chain-of-responsibility.md)
3. [Stream methods](references/_sections.md#3-stream-methods) — **HIGH**
   - 3.1 [Use flatMap for one-to-many transforms instead of nested loops or map().reduce(concat)](references/stream-flatmap-over-nested-loops.md)
4. [Placement and identity](references/_sections.md#4-placement-and-identity) — **HIGH**
   - 4.1 [Place pure transformer lambdas at module scope, not inside a component or hook](references/place-module-scope-pure-transformers.md)
5. [Closures and data-carrying functions](references/_sections.md#5-closures-and-data-carrying-functions) — **MEDIUM**
   - 5.1 [Store a closure in the queue instead of a Command class when nothing inspects or serializes it](references/closure-as-command.md)

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