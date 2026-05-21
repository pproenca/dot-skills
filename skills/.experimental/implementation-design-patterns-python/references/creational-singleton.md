---
title: Use Singleton to Guarantee a Single Shared Instance
impact: MEDIUM
impactDescription: enforces exactly one instance of a shared resource (config, registry, connection pool, logger) via module-import caching or `functools.cache`, prevents duplicate instantiation that diverges state, and keeps the object injectable for tests instead of a hidden global
tags: creational, singleton, module-global, functools-cache, shared-instance
---

## Use Singleton to Guarantee a Single Shared Instance

**Pattern intent:** ensure a class has exactly one instance and provide one access point to it. Python already gives you this: a **module is imported once**, so a module-level object is a process-wide singleton, and `functools.cache` turns any factory into a lazily-initialized one. The classic `__new__`/metaclass machinery is rarely the right tool.

### Shapes to recognize

- A config, logger, registry, or connection pool that *must* be shared across the program
- Bug reports where two parts of the system disagree because each built its own instance
- A module-level `_instance = None` guarded by a `get_instance()` — a singleton in disguise
- "I need one shared object, but I don't want a bare mutable global scattered around"

### Problem

Two concerns at once: guarantee a single instance of a class managing a shared resource (pool, config), and give the program one place to reach it. A plain constructor always returns a fresh object, so two callers silently get two instances whose state drifts apart.

### Solution

Prefer a module-level instance (created once at import) or a `@functools.cache` factory for lazy creation. Both give one shared instance and one named access point — and unlike a hidden global, both can be swapped in tests.

**Incorrect (custom `__new__` singleton — fights the language, resists testing):**

```python
class Config:
    _instance = None
    def __new__(cls):
        if cls._instance is None:           # also not thread-safe without a lock
            cls._instance = super().__new__(cls)
        return cls._instance
    # Hard to substitute in tests; hides that everyone shares mutable state.
```

**Correct (lazy factory via `functools.cache`):**

```python
from functools import cache

class Config:
    def __init__(self) -> None:
        self.theme = "light"

@cache
def get_config() -> Config:
    """First call builds the instance; every later call returns the cached one."""
    return Config()

a = get_config()
b = get_config()
a.theme = "dark"
print(a is b, b.theme)
```

**Output:**

```text
True dark
```

**Alternative (module-level instance — the simplest singleton):**

```python
# settings.py
class _Settings:
    def __init__(self) -> None:
        self.theme = "light"

settings = _Settings()   # built once when the module is first imported

# elsewhere:  from settings import settings
```

### When to use

- The program needs exactly one instance of a shared resource for its whole lifetime
- You want lazy initialization — pay the construction cost only on first access (`@cache`)
- You want one obvious, named access point rather than a free-floating mutable global

### When NOT to use

- You reach for it only to avoid passing the object around — that is hidden coupling and hurts tests
- Tests must substitute the instance frequently — prefer dependency injection or `get_config.cache_clear()`
- The "singleton" is really immutable config — a module-level constant or frozen dataclass is plainer
- State must differ per request/thread/task — a singleton is the wrong scope; use a context var

### Implementation Steps

1. Default to a module-level instance when no lazy init is needed
2. For lazy creation, write a factory function and decorate it with `functools.cache`
3. Import the instance/accessor where needed instead of constructing the class
4. In tests, override the dependency or call `factory.cache_clear()` to reset
5. Keep the singleton's data immutable where possible to avoid cross-context drift

### Pros

- Guarantees one instance with a single, named access point
- `@cache` gives thread-safe lazy initialization for free
- Stays testable: the accessor is a seam you can monkeypatch or clear

### Cons

- Couples callers to a global and can mask poor design — singletons are easy to overuse
- Mutable singletons across async tasks, threads, or processes diverge unless guarded
- Module-import singletons run their construction at import time, which can surprise

### Related Patterns

- **Facade** — facades are often singletons because one instance suffices
- **Flyweight** — looks similar but allows many instances (one per intrinsic state) and is immutable
- **Abstract Factory / Builder** — frequently exposed as a module-level singleton instance

Reference: [refactoring.guru/design-patterns/singleton/python](https://refactoring.guru/design-patterns/singleton/python/example)
