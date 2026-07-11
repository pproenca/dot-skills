---
title: Use z.ipv4()/z.ipv6()/z.cidrv4()/z.cidrv6() — .ip() and .cidr() are removed
tags: gone, string-formats, network, removed-api
---

## Use z.ipv4()/z.ipv6()/z.cidrv4()/z.cidrv6() — .ip() and .cidr() are removed

The wrong default is the Zod 3 form `z.string().ip()` / `z.string().cidr()`. Unlike the other string-format methods (which are deprecated but still work), these two were **removed** in zod@4.0 — the code does not compile against zod@4. The replacements are version-specific top-level schemas; when both versions are acceptable, union them.

**Evidence of violation:** `.ip(` or `.cidr(` chained on a Zod string schema.

**Incorrect (removed in 4.0 — does not compile):**

```ts
const AllowlistEntry = z.object({
  address: z.string().ip({ version: "v4" }),
  range: z.string().cidr(),
})
```

**Correct (top-level, version-explicit):**

```ts
const AllowlistEntry = z.object({
  address: z.ipv4(),
  range: z.union([z.cidrv4(), z.cidrv6()]),
})
```

Reference: [Zod 4 changelog — removed string methods](https://zod.dev/v4/changelog)
