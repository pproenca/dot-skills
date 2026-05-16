---
title: Avoid Options Bags Where Every Caller Passes the Same Values
impact: MEDIUM
impactDescription: eliminates options-object plumbing for parameters that have one value
tags: spec, options, generality, yagni
---

## Avoid Options Bags Where Every Caller Passes the Same Values

An options object is right when callers genuinely want to control different fields — some pass `{ retries: 3 }`, some pass `{ timeout: 5000 }`, some pass both. When *every* caller passes the same options (or the function has one caller and the bag has one field), the bag is a future-proofing tax. Each option is documented, defaulted, validated, and threaded through — for no live benefit. Add the option when a second caller actually needs to override.

**Incorrect (options bag where every option has one fixed value at every call site):**

```typescript
type FetchOptions = {
  timeout?: number;
  retries?: number;
  cache?: 'no-store' | 'force-cache';
  headers?: Record<string, string>;
};

async function fetchUser(id: string, options: FetchOptions = {}): Promise<User> {
  const timeout = options.timeout ?? 5000;
  const retries = options.retries ?? 3;
  const cache   = options.cache ?? 'no-store';
  const headers = { ...DEFAULT_HEADERS, ...options.headers };
  // ... uses all four
}

// All three call sites:
await fetchUser(id);
await fetchUser(otherId);
await fetchUser(anotherId);
// No caller overrides any option. The bag, the defaults, and the type all earn nothing.
```

**Correct (until a caller actually needs to override):**

```typescript
async function fetchUser(id: string): Promise<User> {
  const timeout = 5000;
  const retries = 3;
  const cache   = 'no-store';
  // ... uses constants
}
// When a real second caller wants a 30s timeout, add `timeout?: number` then.
// The bag earns its keep when the variability is real, not anticipated.
```

**The "I might need it later" objection:**

You might. Adding a parameter is a 5-minute refactor when "later" arrives. The bag costs you every day until then: each option doubles the test surface, each default is a hidden decision, each consumer reads option-handling code instead of the function's actual logic.

**Variations of the same anti-pattern:**

- A function with three positional parameters, all of which are the same value at every call site.
- A class constructor that takes `config: Config` where `Config` has 10 fields and every call passes the same `DEFAULT_CONFIG`.
- A React component with 12 props, of which 8 always receive the same value (lift defaults; consider whether the component is doing too much).
- A CLI flag that no one ever sets — remove until someone asks.

**Symptoms:**

- An options type with 4+ fields and a function body that's mostly default-merging.
- Grep for the function: every call site passes `{}` or the same shape.
- "Configurable" abstractions that are only ever configured one way.
- Documentation that says "options for future extensibility."

**When NOT to use this pattern:**

- The function is a public library API where the *promise* of options is part of the contract — keep them, but minimise.
- Two callers exist today with different needs — the bag earns its keep. Make sure the *third* caller would, too.
- The options control fundamentally different code paths (retries vs cache strategy) and you expect both to be used.

Reference: [YAGNI](https://martinfowler.com/bliki/Yagni.html); [Premature generalisation](https://wiki.c2.com/?PrematureGeneralization)
