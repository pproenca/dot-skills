---
title: Use Strategy to Make Algorithms Interchangeable at Runtime
impact: HIGH
impactDescription: eliminates the `if mode == "a" ... elif mode == "b"` ladder that selects an algorithm inside business code, enables runtime swapping of algorithm variants, isolates each algorithm as an independently testable function
tags: behavioral, strategy, callable, first-class-functions, runtime-swap
---

## Use Strategy to Make Algorithms Interchangeable at Runtime

**Pattern intent:** define a family of interchangeable algorithms and let the caller choose one at runtime. Because Python functions are first-class, a strategy is usually just a **`Callable` passed in** — no Strategy interface or concrete-strategy classes required.

### Shapes to recognize

- A method that branches on `mode`/`kind`/`type` to pick an algorithm
- Several variants of the same operation (sort, route, price, compress) chosen at runtime
- A class growing every time a new algorithm variant is added
- "I want to swap how this is computed without subclassing or editing the caller"

### Problem

A navigation app supports car and walking routes, with cyclist and transit planned. Encoding each as a branch inside `Navigator` swells the class, raises bug risk, and makes every new mode a merge-conflict-prone edit to the same method.

### Solution

Make the algorithm a `Callable` the context holds and delegates to. Each variant is a plain function; switching is one assignment. The context never knows which algorithm it runs.

**Incorrect (algorithm-selection conditional inside the context):**

```python
class Navigator:
    def build(self, mode: str, start: str, end: str) -> list[str]:
        if mode == "car":
            return [start, "highway", end]
        elif mode == "walking":
            return [start, "park path", end]
        # Adding "cyclist" edits this method (and every other shaped like it).
        raise ValueError(mode)
```

**Correct (interchangeable strategy functions):**

```python
from collections.abc import Callable

Route = Callable[[str, str], list[str]]

def car_route(start: str, end: str) -> list[str]:
    return [start, "highway", end]

def walking_route(start: str, end: str) -> list[str]:
    return [start, "park path", end]

class Navigator:
    def __init__(self, strategy: Route) -> None:
        self.strategy = strategy
    def build(self, start: str, end: str) -> list[str]:
        return self.strategy(start, end)     # delegate to the chosen algorithm

nav = Navigator(car_route)
print(nav.build("home", "work"))
nav.strategy = walking_route                 # swap at runtime: one assignment
print(nav.build("home", "work"))
```

**Output:**

```text
['home', 'highway', 'work']
['home', 'park path', 'work']
```

### When to use

- You have several variants of an algorithm and want to choose one at runtime
- A class has large conditionals selecting an algorithm
- You want each algorithm isolated and independently testable

### When NOT to use

- There's one stable algorithm that rarely changes — a function call suffices
- The algorithm must be fixed at definition time and never swap — inheritance/Template Method is enough
- The strategy needs significant configuration or state — then a small class is warranted over a bare function

### Implementation Steps

1. Identify the algorithm in the context that varies
2. Define the strategy as a `Callable` type alias capturing its signature
3. Write each variant as a plain function matching that signature
4. Give the context a strategy attribute and delegate to it
5. Let callers pass or reassign the strategy; reach for a class only if the strategy needs state

### Pros

- Swap algorithms at runtime with a single assignment
- Each algorithm is isolated and testable in isolation
- Replaces inheritance with composition (Open/Closed for new strategies)

### Cons

- For a few stable algorithms, the indirection adds little
- Callers must understand the variants to choose correctly

### Related Patterns

- **State** — same shape; State objects self-transition and know each other, Strategy variants are independent
- **Template Method** — varies steps via inheritance (compile-time); Strategy swaps the whole algorithm (runtime)
- **Command** — both wrap behavior; Command represents a request, Strategy an algorithm
- **Decorator** — changes the outer skin; Strategy changes the inner algorithm

Reference: [refactoring.guru/design-patterns/strategy/python](https://refactoring.guru/design-patterns/strategy/python/example)
