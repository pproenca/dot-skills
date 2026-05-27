---
title: Use Singleton to Guarantee a Single Shared Instance
impact: MEDIUM
impactDescription: enforces exactly one instance of a shared resource (config, registry, connection pool, logger), prevents accidental duplicate instantiation that diverges state, and provides a single named access point that's easy to find and replace
tags: creational, singleton, global-access, shared-instance, lazy-initialization
---

## Use Singleton to Guarantee a Single Shared Instance

**Pattern intent:** a class has exactly one instance and provides a global access point to it. Subsequent attempts to construct it return the cached instance.

### Shapes to recognize

- Configuration object, logger, registry, or connection pool that *must* be shared across the program
- Bug reports where two parts of the system disagree because each created its own instance
- A module-scope `let cached: T | null = null` with a `getInstance()` that lazy-initializes — already a Singleton in disguise
- "I need a global, but I don't want a free-floating mutable variable"

### Problem

Two concerns at once: enforce a single instance of a class controlling a shared resource (database, pool, config), and provide a controlled access point. Plain constructors always return a new object — the language can't enforce uniqueness on its own.

### Solution

Make the constructor private (or otherwise unreachable). Expose a static accessor that returns the cached instance, creating it on first access (lazy initialization). Clients use the accessor instead of `new`.

**Incorrect (independent instances drift apart):**

```typescript
class AppConfig {
  public theme: 'light' | 'dark' = 'light';
}

// Two callers, two instances — toggling one doesn't affect the other.
const configA = new AppConfig();
const configB = new AppConfig();
configA.theme = 'dark';
console.log(configB.theme); // still 'light' — divergence
```

**Correct (private constructor, static accessor):**

```typescript
/**
 * The Singleton class defines an `instance` getter, that lets clients access
 * the unique singleton instance.
 */
class Singleton {
    static #instance: Singleton;

    /**
     * The Singleton's constructor should always be private to prevent direct
     * construction calls with the `new` operator.
     */
    private constructor() { }

    /**
     * The static getter that controls access to the singleton instance.
     *
     * This implementation allows you to extend the Singleton class while
     * keeping just one instance of each subclass around.
     */
    public static get instance(): Singleton {
        if (!Singleton.#instance) {
            Singleton.#instance = new Singleton();
        }

        return Singleton.#instance;
    }

    /**
     * Finally, any singleton can define some business logic, which can be
     * executed on its instance.
     */
    public someBusinessLogic() {
        // ...
    }
}

function clientCode() {
    const s1 = Singleton.instance;
    const s2 = Singleton.instance;

    if (s1 === s2) {
        console.log(
            'Singleton works, both variables contain the same instance.'
        );
    } else {
        console.log('Singleton failed, variables contain different instances.');
    }
}

clientCode();
```

**Output:**

```text
Singleton works, both variables contain the same instance.
```

### When to use

- The program needs *exactly one* instance of a class for the lifetime of the process
- You need stricter control over a global than a free-floating mutable variable provides
- You want lazy initialization — pay the cost only when first accessed
- You need to guarantee an instance can't be silently replaced

### When NOT to use

- You're using it just to avoid passing the object around — that's hidden coupling and makes unit tests painful
- Tests need to substitute the instance frequently — Singleton resists injection
- In TypeScript, a module-scope `export const config = createConfig()` is usually a better Singleton: ESM caches modules, the constant is shared, and tests can mock the module
- Mutable Singletons across an async/multi-tab boundary diverge — prefer immutable config or per-context instances

### Implementation Steps

1. Add a private static field that stores the singleton instance
2. Declare a public static accessor (getter or method)
3. Lazy-initialize inside the accessor on first call
4. Make the class constructor private
5. Replace direct constructor calls in client code with calls to the accessor

### Pros

- Guarantees exactly one instance
- Provides a single, named global access point
- Instance initialization happens only when first requested

### Cons

- Violates Single Responsibility Principle (manages lifecycle *and* business logic)
- Can mask poor design and excessive component coupling — Singletons are easy to overuse
- Requires careful handling in multithreaded environments (less of an issue in single-threaded JavaScript)
- Hard to unit test — private constructors and static state resist mocking

### Related Patterns

- **Facade** — Facade classes are often implemented as Singletons because one instance is enough
- **Flyweight** — looks like Singleton but allows multiple instances (one per intrinsic state) and is immutable
- **Abstract Factory / Builder / Prototype** — often implemented as Singletons in classic GoF (rarely advisable in modern TS — a module-scope `export const factory = createFactory()` is simpler and more testable)

Reference: [refactoring.guru/design-patterns/singleton](https://refactoring.guru/design-patterns/singleton)
