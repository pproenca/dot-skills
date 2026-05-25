---
title: Prefer Erasable Syntax Over Enums and Namespaces
impact: HIGH
impactDescription: keeps code runnable under Node.js type-stripping
tags: modern, erasable-syntax, enums, namespaces
---

## Prefer Erasable Syntax Over Enums and Namespaces

TypeScript's runtime-emitting constructs — `enum`, `namespace`/`module`, parameter properties, and legacy `experimentalDecorators` — cannot be erased to plain JavaScript; they require code generation. Node.js native type-stripping (23.6+) and TypeScript's `erasableSyntaxOnly` flag (5.8) reject them, and TypeScript 6.0 turns the old `module Foo {}` form into an error. Code built from erasable syntax runs unchanged anywhere types are simply stripped.

**Incorrect (enum + namespace — non-erasable, fails type-stripping):**

```typescript
export enum LogLevel { Debug, Info, Warn, Error }

export namespace Logger {
  export function format(level: LogLevel): string {
    return LogLevel[level]
  }
}
```

**Correct (const object + module exports — fully erasable):**

```typescript
export const LogLevel = {
  Debug: 0, Info: 1, Warn: 2, Error: 3,
} as const
export type LogLevel = (typeof LogLevel)[keyof typeof LogLevel]

export function format(level: LogLevel): string {
  return Object.keys(LogLevel)[level]
}
```

Set `"erasableSyntaxOnly": true` in `tsconfig.json` to catch non-erasable syntax at compile time. If you genuinely need decorators, use the Stage 3 standard form (TS 5.0), not `experimentalDecorators`. See [`perf-union-literals-over-enums`](perf-union-literals-over-enums.md) for the enum-to-union refactor.

Reference: [TypeScript 5.8 — erasableSyntaxOnly](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-8.html)
