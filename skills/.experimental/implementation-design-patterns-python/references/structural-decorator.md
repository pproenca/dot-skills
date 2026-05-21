---
title: Use Decorator to Attach Behaviors at Runtime via Wrappers
impact: HIGH
impactDescription: reduces N x M subclass explosion (every combination like CompressedEncryptedStream) to a few small wrappers stacked at runtime, eliminates duplicated wrapping code, enables adding or removing responsibilities dynamically
tags: structural, decorator, wrapper, functools-wraps, composition
---

## Use Decorator to Attach Behaviors at Runtime via Wrappers

**Pattern intent:** attach new responsibilities to an object by wrapping it in another object with the same interface, stackable in any order. Note the name clash: the GoF *Decorator pattern* wraps an **object**; Python's `@decorator` syntax wraps a **function**. Both share the idea — wrap to add behavior — and this entry covers the object form, with the function form as the idiomatic shortcut.

### Shapes to recognize

- Combinations modeled as subclasses: `CompressedStream`, `EncryptedStream`, `CompressedEncryptedStream`
- Cross-cutting behavior (logging, caching, retry, compression) you want to add per-instance
- "I need to layer two or three behaviors, and any subset, chosen at runtime"
- Repeated boilerplate that wraps a call to add the same before/after logic

### Problem

A data stream sometimes needs compression, sometimes encryption, sometimes both, in either order. Modeling each combination as a subclass produces a class per subset — and the count doubles with every new behavior.

### Solution

Define the base interface as a `Protocol`. Each decorator implements that interface, holds the wrapped object, and adds behavior before/after delegating. Stack them at runtime; the outermost wrapper is called first.

**Incorrect (a subclass per behavior combination):**

```python
class FileStream: ...
class CompressedStream(FileStream): ...
class EncryptedStream(FileStream): ...
class CompressedEncryptedStream(FileStream): ...   # and EncryptedCompressedStream, and...
# Add "base64" and you double the subclass count again.
```

**Correct (small wrappers sharing one interface, stacked at runtime):**

```python
from typing import Protocol

class DataSource(Protocol):
    def write(self, data: str) -> str: ...

class FileSource:
    def write(self, data: str) -> str:
        return data                       # the concrete component

class CompressionDecorator:
    def __init__(self, wrappee: DataSource) -> None:
        self._wrappee = wrappee
    def write(self, data: str) -> str:
        return self._wrappee.write(f"zip({data})")

class EncryptionDecorator:
    def __init__(self, wrappee: DataSource) -> None:
        self._wrappee = wrappee
    def write(self, data: str) -> str:
        return self._wrappee.write(f"aes({data})")

# Choose the stack at runtime; outermost runs first.
source: DataSource = EncryptionDecorator(CompressionDecorator(FileSource()))
print(source.write("payroll"))
```

**Output:**

```text
zip(aes(payroll))
```

**Alternative (function decorator with `functools.wraps` for behavior on callables):**

```python
import functools

def retry(times: int):
    def deco(fn):
        @functools.wraps(fn)              # preserve name/docstring/signature
        def inner(*args, **kwargs):
            for attempt in range(times):
                try:
                    return fn(*args, **kwargs)
                except ConnectionError:
                    if attempt == times - 1:
                        raise
        return inner
    return deco
```

### When to use

- You want to add or remove responsibilities at runtime, in arbitrary combinations
- Subclassing for every combination would explode the class count
- The added behavior wraps an existing interface rather than changing it

### When NOT to use

- Only one behavior will ever be added — a subclass or a parameter is simpler
- The wrappers need to know each other's order in fragile ways — that coupling defeats the pattern
- You are decorating a *function*, not an object — use Python's `@decorator` syntax instead

### Implementation Steps

1. Declare the component interface as a `Protocol`
2. Implement the concrete component (the thing being wrapped)
3. For each behavior, write a decorator that stores the wrappee and implements the interface
4. Add behavior before/after the delegated call inside each decorator method
5. Compose the stack at runtime by nesting constructors

### Pros

- Extend behavior without subclassing, and combine behaviors freely
- Add or remove responsibilities at runtime (Single Responsibility per wrapper)
- Avoids the combinatorial subclass explosion

### Cons

- Hard to remove a specific wrapper from deep in a stack
- Behavior depends on wrapping order, which can be non-obvious
- Many tiny wrapper classes can clutter a codebase

### Related Patterns

- **Composite** — both wrap recursively; Composite aggregates children, Decorator adds one responsibility and passes through
- **Adapter** — changes an interface; Decorator keeps the interface and enriches it
- **Proxy** — same interface but controls access/lifecycle rather than adding behavior
- **Strategy** — changes the *inner* algorithm; Decorator changes the *outer* skin

Reference: [refactoring.guru/design-patterns/decorator/python](https://refactoring.guru/design-patterns/decorator/python/example)
