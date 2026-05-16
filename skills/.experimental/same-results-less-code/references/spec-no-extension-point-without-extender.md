---
title: Delete Extension Points That Have No Second User
impact: MEDIUM
impactDescription: eliminates hook/plugin/registry machinery that no one extends
tags: spec, plugins, extensibility, yagni
---

## Delete Extension Points That Have No Second User

A plugin system, a strategy registry, a lifecycle-hook framework, or an event bus all carry real cost: documentation, type contracts, registration order, error handling at the boundary, debugging stories. They're worth it when *several* extenders use them — that's the whole point. When the only "extender" is the system itself (one built-in plugin, one strategy, one hook handler), the machinery is a future-proofing tax for a future that hasn't shown up. Replace it with a direct call until the second extender appears.

**Incorrect (a plugin system with one plugin):**

```typescript
// plugins/types.ts
export interface FormatterPlugin {
  name: string;
  priority: number;
  canHandle(value: unknown): boolean;
  format(value: unknown): string;
}

// plugins/registry.ts
export class FormatterRegistry {
  private plugins: FormatterPlugin[] = [];
  register(p: FormatterPlugin) { this.plugins.push(p); this.plugins.sort((a, b) => b.priority - a.priority); }
  format(value: unknown): string {
    const plugin = this.plugins.find(p => p.canHandle(value));
    if (!plugin) throw new Error('No formatter for value');
    return plugin.format(value);
  }
}

// plugins/currency-formatter.ts (the only plugin):
export const currencyFormatter: FormatterPlugin = {
  name: 'currency',
  priority: 1,
  canHandle: (v): boolean => typeof v === 'number',
  format: (v) => `$${(v as number).toFixed(2)}`,
};

// At startup:
const registry = new FormatterRegistry();
registry.register(currencyFormatter);

// At use:
const text = registry.format(99.99);
// 30 lines of plugin machinery so one function can be looked up.
```

**Correct (just call the function):**

```typescript
export const formatCurrency = (v: number): string => `$${v.toFixed(2)}`;

// At use:
const text = formatCurrency(99.99);
// Zero plugin machinery. When a second formatter type appears, build the registry then —
// it's a 10-minute refactor.
```

**Other "machinery for one":**

- An `EventBus` with one event type, one publisher, one subscriber — just call the function.
- A `Strategy` interface with one strategy — just write the function.
- A middleware chain with one middleware — just inline the middleware's logic.
- A pluggable `LogAdapter` with one adapter (`ConsoleLogAdapter`) — just use console (or a real library).
- A `Pipeline` that runs steps from a list when the list has one step — just call the step.

**Symptoms:**

- A registry/manager/coordinator whose register-method is called exactly once.
- An abstract base with one concrete subclass.
- A factory whose `create` method has one possible return type.
- A hook lifecycle (`beforeX`, `onX`, `afterX`) where only `onX` ever gets a handler.

**When NOT to use this pattern:**

- The extension point is part of a public API where third-party extenders will plug in — keep it; it's the contract.
- Multiple extensions exist *today*, even if some are trivial — the polymorphism is real.
- The plugin model lets you load extensions at runtime (a real plugin system) — that's a different problem, and the machinery earns its keep.

Reference: [Mathias Verraes — Speculative generality](https://verraes.net/2019/12/speculative-generality/)
