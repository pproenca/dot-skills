---
title: Use Bridge to Split Abstraction from Implementation
impact: MEDIUM
impactDescription: prevents exponential subclass explosion when a type varies along two independent dimensions (control type x device type), lets the abstraction and implementation evolve separately, enables swapping the implementation at runtime
tags: structural, bridge, composition, protocol, orthogonal-dimensions
---

## Use Bridge to Split Abstraction from Implementation

**Pattern intent:** when a class varies along two independent dimensions, split it into an *abstraction* hierarchy and an *implementation* hierarchy linked by composition, so each side grows on its own. In Python the implementation side is a `Protocol`; the abstraction holds a reference to it and delegates.

### Shapes to recognize

- Subclass names that multiply two axes: `TVRemote`, `RadioRemote`, `AdvancedTVRemote`, `AdvancedRadioRemote`
- A `Shape` x `Color` (or `UI` x `Platform`, `Document` x `Renderer`) matrix headed for `m * n` classes
- Two things changing for unrelated reasons crammed into one inheritance tree
- "Every time I add a device I have to add it to every kind of remote"

### Problem

A remote control comes in basic and advanced variants and must drive TVs and radios. Modeling this with inheritance gives a class per *combination* — adding a streaming box or a third remote type multiplies the count, and shared logic gets copied across siblings.

### Solution

Treat "remote" (abstraction) and "device" (implementation) as separate hierarchies. The remote holds a `Device` and delegates to it; remote variants extend the abstraction, device variants implement the `Protocol`. Any remote works with any device — `m + n` classes instead of `m * n`.

**Incorrect (one class per combination — `m * n` explosion):**

```python
class BasicTVRemote: ...
class BasicRadioRemote: ...
class AdvancedTVRemote: ...
class AdvancedRadioRemote: ...
# Add a streaming box, or a "kids" remote, and the matrix grows again.
```

**Correct (abstraction composes an implementation Protocol):**

```python
from typing import Protocol

class Device(Protocol):                    # implementation side
    def get_volume(self) -> int: ...
    def set_volume(self, pct: int) -> None: ...
    def name(self) -> str: ...

class TV:
    def __init__(self) -> None: self._vol = 0
    def get_volume(self) -> int: return self._vol
    def set_volume(self, pct: int) -> None: self._vol = max(0, min(100, pct))
    def name(self) -> str: return "TV"

class Radio:
    def __init__(self) -> None: self._vol = 0
    def get_volume(self) -> int: return self._vol
    def set_volume(self, pct: int) -> None: self._vol = max(0, min(100, pct))
    def name(self) -> str: return "Radio"

class RemoteControl:                        # abstraction side
    def __init__(self, device: Device) -> None:
        self._device = device

    def volume_up(self) -> None:
        self._device.set_volume(self._device.get_volume() + 10)

class AdvancedRemote(RemoteControl):        # extends abstraction, not the matrix
    def mute(self) -> None:
        self._device.set_volume(0)

remote = AdvancedRemote(TV())              # any remote x any device
remote.volume_up()
print(f"{remote._device.name()} @ {remote._device.get_volume()}%")
```

**Output:**

```text
TV @ 10%
```

### When to use

- A class varies along two (or more) independent dimensions
- You want to extend each dimension without touching the other
- You need to switch the implementation at runtime (pass a different `Device`)

### When NOT to use

- There is only one dimension of variation — plain composition or a strategy is enough
- The two hierarchies are tiny and stable — the indirection costs more than it saves
- You are retrofitting cooperation between existing incompatible classes — that is **Adapter**

### Implementation Steps

1. Identify the two independent dimensions in the bloated class
2. Declare a `Protocol` for the implementation dimension (the lower-level operations)
3. Give the abstraction a field holding an implementation and delegate primitive operations to it
4. Extend the abstraction with refined variants that combine the primitive operations
5. Implement the `Protocol` once per concrete implementation; inject it through the constructor

### Pros

- Decouples interface from implementation — `m + n` classes instead of `m * n`
- Each hierarchy evolves and ships independently (Open/Closed)
- Implementations are swappable at runtime through composition

### Cons

- Upfront design overhead; over-applied to a class with only one axis it just adds layers
- The indirection can obscure simple cases

### Related Patterns

- **Strategy** — same composition shape for one varying behavior; Bridge separates two whole hierarchies
- **Abstract Factory** — can create and pair matching abstraction/implementation objects
- **Adapter** — makes existing classes cooperate after the fact; Bridge is designed in up front
- **State** — also delegates to a swapped object, but to change behavior as state changes

Reference: [refactoring.guru/design-patterns/bridge/python](https://refactoring.guru/design-patterns/bridge/python/example)
