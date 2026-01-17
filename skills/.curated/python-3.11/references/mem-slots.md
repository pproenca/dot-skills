---
title: Use __slots__ for Memory-Efficient Classes
impact: HIGH
impactDescription: 20-50% memory reduction per instance
tags: mem, slots, classes, optimization
---

## Use __slots__ for Memory-Efficient Classes

By default, Python stores instance attributes in a `__dict__` dictionary. `__slots__` replaces this with a fixed-size array, reducing memory and speeding up attribute access.

**Incorrect (dict-based attributes):**

```python
class Point:
    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z

# Each instance uses ~296 bytes for __dict__
points = [Point(i, i, i) for i in range(100_000)]
# Total: ~30MB
```

**Correct (slot-based attributes):**

```python
class Point:
    __slots__ = ("x", "y", "z")

    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z

# Each instance uses ~64 bytes (fixed slots)
points = [Point(i, i, i) for i in range(100_000)]
# Total: ~6.4MB
```

**Benefits:**
- 20-50% memory reduction per instance
- 10-20% faster attribute access
- Prevents accidental attribute creation

**When NOT to use __slots__:**
- When you need dynamic attribute creation
- When subclasses need their own `__dict__`
- For classes with few instances

Reference: [Python Wiki - Using Slots](https://wiki.python.org/moin/UsingSlots)
