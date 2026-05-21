---
title: Use Proxy to Insert a Substitute Controlling Access to an Object
impact: MEDIUM-HIGH
impactDescription: enables lazy loading, access control, caching, and logging without touching the real subject or duplicating that logic at each call site, preserves the original interface so callers stay unchanged
tags: structural, proxy, getattr-delegation, lazy-loading, access-control
---

## Use Proxy to Insert a Substitute Controlling Access to an Object

**Pattern intent:** stand in for another object, exposing the same interface, to control access to it — deferring its creation, caching results, checking permissions, or logging. In Python, `__getattr__` forwards arbitrary calls to the wrapped subject transparently, and `functools.cached_property` covers the common lazy-attribute case.

### Shapes to recognize

- An expensive object (large file, remote service, DB connection) you'd rather not build until used
- Cross-cutting access logic (auth checks, caching, call logging) you don't want inside the real class
- "I want lazy loading / a permission gate / a cache, but callers shouldn't change"
- A wrapper that should forward *most* methods unchanged and intercept only a few

### Problem

A gallery constructs many `RealImage` objects up front; each reads megabytes from disk on construction. Most images are never displayed, so the program pays the full load cost for images the user never opens.

### Solution

Insert a proxy that implements the same interface and holds the construction parameters, deferring creation of the real subject until a method actually needs it. Callers use the proxy exactly like the real object.

**Incorrect (eager construction loads everything up front):**

```python
class RealImage:
    def __init__(self, path: str) -> None:
        self._path = path
        print(f"loading {path} from disk")   # happens for ALL images immediately
    def display(self) -> str:
        return f"<{self._path}>"

gallery = [RealImage(f"img{i}.png") for i in range(3)]   # 3 disk loads, 0 displayed yet
```

**Correct (proxy defers creation until first real use):**

```python
from typing import Protocol

class Image(Protocol):
    def display(self) -> str: ...

class RealImage:
    def __init__(self, path: str) -> None:
        self._path = path
        print(f"loading {path} from disk")
    def display(self) -> str:
        return f"<{self._path}>"

class LazyImageProxy:
    def __init__(self, path: str) -> None:
        self._path = path
        self._real: RealImage | None = None
    def display(self) -> str:
        if self._real is None:                # build the real subject on first use
            self._real = RealImage(self._path)
        return self._real.display()

gallery: list[Image] = [LazyImageProxy(f"img{i}.png") for i in range(3)]
print("constructed; nothing loaded yet")
print(gallery[0].display())                   # only this one loads
```

**Output:**

```text
constructed; nothing loaded yet
loading img0.png from disk
<img0.png>
```

**Alternative (`__getattr__` forwards everything else; intercept selectively):**

```python
class LoggingProxy:
    def __init__(self, subject: object) -> None:
        self._subject = subject
    def __getattr__(self, name: str):          # called only for unresolved attributes
        attr = getattr(self._subject, name)
        print(f"access: {name}")
        return attr
```

### When to use

- Lazy initialization (virtual proxy): defer building an expensive object until needed
- Access control (protection proxy): check permissions before forwarding
- Caching / logging / remote access: add a layer around the subject transparently

### When NOT to use

- The control logic belongs in the real object itself — a proxy just adds indirection
- You only need lazy *attributes* — `functools.cached_property` is simpler than a proxy class
- You are adding stackable behavior, not controlling access — that is **Decorator**

### Implementation Steps

1. Define (or reuse) the subject's interface as a `Protocol`
2. Create a proxy that implements that interface and references the real subject (or its parameters)
3. Add the control logic (lazy create, auth, cache) in the proxy's methods before delegating
4. Use `__getattr__` to forward any methods the proxy doesn't override
5. Hand callers the proxy where they expected the real subject — they need no changes

### Pros

- Controls the subject's lifecycle and access without changing it or the callers
- Cross-cutting concerns live in one place (Single Responsibility, Open/Closed)
- `__getattr__` makes transparent forwarding nearly free

### Cons

- Adds a layer and can mask latency (a "cheap" call quietly triggers a load)
- A proxy that forwards via `__getattr__` can confuse type checkers and `hasattr` logic

### Related Patterns

- **Decorator** — same wrapping shape, but adds behavior rather than controlling access
- **Adapter** — changes the interface; Proxy keeps it identical
- **Facade** — simplifies a whole subsystem; Proxy stands in for one object with the same interface
- **Singleton** — a proxy may guard access to a single shared real subject

Reference: [refactoring.guru/design-patterns/proxy/python](https://refactoring.guru/design-patterns/proxy/python/example)
