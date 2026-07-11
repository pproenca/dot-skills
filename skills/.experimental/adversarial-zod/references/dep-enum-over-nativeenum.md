---
title: Pass TypeScript enums to z.enum() — z.nativeEnum() is deprecated
tags: dep, enums, deprecated-api
---

## Pass TypeScript enums to z.enum() — z.nativeEnum() is deprecated

The wrong default is `z.nativeEnum(MyEnum)` for TypeScript enums. In zod@4, `z.enum()` accepts enum-like objects directly, and `z.nativeEnum()` is deprecated. The `.Values` and `.Enum` accessors on enum schemas were removed as well — only `.enum` remains.

**Evidence of violation:** `z.nativeEnum(`; `.Values` or `.Enum` accessed on a Zod enum schema (removed — does not compile).

**Incorrect (deprecated constructor, removed accessors):**

```ts
enum OrderStatus { Pending = "pending", Shipped = "shipped" }

const Status = z.nativeEnum(OrderStatus)
const values = Status.Values
```

**Correct (z.enum handles both forms, .enum is the accessor):**

```ts
enum OrderStatus { Pending = "pending", Shipped = "shipped" }

const Status = z.enum(OrderStatus)
const values = Status.enum // { Pending: "pending", Shipped: "shipped" }
```

Reference: [Zod 4 changelog — z.nativeEnum() deprecation](https://zod.dev/v4/changelog)
