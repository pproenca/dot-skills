---
title: Prefer Named Exports over Default Exports
impact: LOW-MEDIUM
impactDescription: enables reliable rename and autocomplete
tags: idiom, exports, named-exports, refactoring
---

## Prefer Named Exports over Default Exports

A default export has no name at the import boundary — importers may call it anything — so editor rename refactors and auto-import frequently miss it, and it interoperates awkwardly with CommonJS under `esModuleInterop`. Named exports keep a stable identity that tooling tracks across the whole codebase, which matters most while a migration is reshaping many modules at once.

**Incorrect (default export — identity lost across the boundary):**

```typescript
// Each importer picks its own local name, so rename and autocomplete
// cannot follow this symbol reliably.
export default function createPaymentGateway(config: GatewayConfig): PaymentGateway {
  return new StripeGateway(config)
}
```

**Correct (named export — stable, trackable identity):**

```typescript
export function createPaymentGateway(config: GatewayConfig): PaymentGateway {
  return new StripeGateway(config)
}
```

Reference: [Google TypeScript Style Guide: Exports](https://google.github.io/styleguide/tsguide.html#exports)
