---
title: Enable erasableSyntaxOnly and avoid non-erasable constructs
tags: tscfg, erasable-syntax, enum, namespace
---

## Enable erasableSyntaxOnly and avoid non-erasable constructs

The wrong default is reaching for `enum`, runtime `namespace`, or constructor parameter properties — TypeScript syntax with runtime emit. Vite (Start's bundler) strips types file-by-file, and the whole modern toolchain (Node's native type-stripping included) assumes types erase cleanly; non-erasable constructs are the exception that breaks that assumption. `erasableSyntaxOnly` (TS 5.8+) turns them into compile errors. For enum semantics, an `as const` object plus a derived union gives the same ergonomics with zero runtime footprint.

**Evidence of violation:** `erasableSyntaxOnly` absent or `false` in `tsconfig.json` — or, in code regardless of the flag: an `enum` declaration, a runtime `namespace` body, or a `constructor(private x: ...)` parameter property.

**Incorrect (runtime emit hiding inside type syntax):**

```ts
enum OrderStatus {
  Pending = 'pending',
  Shipped = 'shipped',
}
```

**Correct (erasable — same ergonomics, no runtime footprint):**

```ts
const OrderStatus = {
  Pending: 'pending',
  Shipped: 'shipped',
} as const
type OrderStatus = (typeof OrderStatus)[keyof typeof OrderStatus]
```

Reference: [TSConfig — erasableSyntaxOnly](https://www.typescriptlang.org/tsconfig/erasableSyntaxOnly.html), [TypeScript 5.8 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-8.html)
