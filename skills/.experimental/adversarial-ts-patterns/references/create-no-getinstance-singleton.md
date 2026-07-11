---
title: No getInstance Singleton classes — a module is already a singleton
tags: create, singleton, module-scope, gof
---

## No getInstance Singleton classes — a module is already a singleton

The wrong default is porting the Java Singleton — `private constructor`, `static instance`, `static getInstance()` — into a language whose module system already guarantees single evaluation. An ES module is evaluated once and its exports are shared by every importer, so the class ceremony re-implements a guarantee the runtime provides for free, while adding a mockability problem (the static access point cannot be swapped) and hiding the dependency from every call site that reaches for `Config.getInstance()` mid-function.

**Evidence of violation:** a class with a `private` (or `protected`) constructor plus a static instance field or `getInstance()`-style static accessor. There is no carve-out — lazy construction, the only capability the class form adds, is a module-scope `let` with a `??=` in a plain function.

**Incorrect (Java Singleton in TypeScript):**

```ts
export class AnalyticsClient {
  private static instance: AnalyticsClient
  private constructor(private readonly apiKey: string) {}

  static getInstance(): AnalyticsClient {
    AnalyticsClient.instance ??= new AnalyticsClient(env.ANALYTICS_KEY)
    return AnalyticsClient.instance
  }
}
```

**Correct (module scope is the singleton; lazy if construction costs):**

```ts
let client: AnalyticsClient | undefined

export function getAnalyticsClient(): AnalyticsClient {
  client ??= new AnalyticsClient(env.ANALYTICS_KEY)
  return client
}
```

Reference: [MDN — JavaScript modules (a module is evaluated once, exports shared by all importers)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)
