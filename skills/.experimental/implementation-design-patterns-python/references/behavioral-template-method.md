---
title: Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps
impact: MEDIUM
impactDescription: eliminates duplicated algorithm scaffolding across sibling classes by hoisting the shared sequence into a base method, lets subclasses override only the steps that vary, removes client conditionals that switch on subtype
tags: behavioral, template-method, abc, hook-methods, higher-order-function
---

## Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps

**Pattern intent:** define the skeleton of an algorithm in a base method, deferring some steps to subclasses so they vary the steps without changing the structure. In Python this is an `ABC` with a concrete template method calling `@abstractmethod` steps — or, when no shared state is involved, a **higher-order function** taking the varying steps as callables.

### Shapes to recognize

- Several classes run the same overall sequence with a few differing steps
- Copy-pasted scaffolding (open → process → close) across siblings, differing only in the middle
- Client conditionals that switch on subtype to run slightly different versions
- "These all follow the same recipe; only one or two steps change"

### Problem

CSV and JSON reports both load data, format it, and wrap it with a title — the same sequence — but each duplicates the whole skeleton to vary just the load and format steps. Fixing the shared sequence means editing every report class.

### Solution

Put the fixed sequence in a base-class template method that calls abstract steps. Subclasses override only the steps that vary; the skeleton lives in one place. Optional hook methods provide overridable defaults.

**Incorrect (each class duplicates the whole skeleton):**

```python
class CsvReport:
    def generate(self):
        rows = ["a,1", "b,2"]            # load
        body = "\n".join(rows)          # format
        return f"=== CSV Report ===\n{body}"   # wrap — duplicated below

class JsonReport:
    def generate(self):
        rows = ['{"a":1}', '{"b":2}']   # only load/format differ; wrap is copy-pasted
        body = ",".join(rows)
        return f"=== JSON Report ===\n{body}"
```

**Correct (base template method fixes the skeleton; subclasses fill steps):**

```python
from abc import ABC, abstractmethod

class Report(ABC):
    def generate(self) -> str:           # the template method: the fixed skeleton
        body = self.format(self.load())
        return f"=== {self.title()} ===\n{body}"

    @abstractmethod
    def load(self) -> list[str]: ...
    @abstractmethod
    def format(self, rows: list[str]) -> str: ...

    def title(self) -> str:              # hook: overridable default
        return "Report"

class CsvReport(Report):
    def load(self) -> list[str]:
        return ["a,1", "b,2"]
    def format(self, rows: list[str]) -> str:
        return "\n".join(rows)
    def title(self) -> str:
        return "CSV Report"

print(CsvReport().generate())
```

**Output:**

```text
=== CSV Report ===
a,1
b,2
```

**Alternative (higher-order function when steps need no shared state):**

```python
from typing import Callable

def generate(load: Callable[[], list[str]],
             fmt: Callable[[list[str]], str],
             title: str = "Report") -> str:
    return f"=== {title} ===\n{fmt(load())}"
```

### When to use

- Several classes share an algorithm structure that differs in a few steps
- You want to let subclasses extend only specific steps, not the whole algorithm
- You want to pull duplicated scaffolding into one place

### When NOT to use

- The steps share no state — a higher-order function is simpler than an ABC hierarchy
- Behavior must change at runtime rather than be fixed by subtype — use **Strategy**
- Only one implementation exists — a plain function is enough

### Implementation Steps

1. Break the algorithm into steps and identify which are shared vs. varying
2. Put the fixed sequence in a base-class template method
3. Declare varying steps as `@abstractmethod`; give overridable defaults as hook methods
4. Implement each subclass by overriding only the steps it changes
5. If no shared state exists, prefer a higher-order function taking step callables

### Pros

- Hoists duplicated scaffolding into one place (Single Responsibility)
- Subclasses override only what varies; the skeleton stays consistent
- Hook methods offer optional extension points

### Cons

- Limited by inheritance — behavior is fixed at class-definition time, not runtime
- A rigid skeleton can be awkward when a subclass needs to vary the sequence itself
- Many abstract steps make subclasses tedious to implement

### Related Patterns

- **Strategy** — composition and runtime swap; Template Method uses inheritance and compile-time steps
- **Factory Method** — often a single step within a template method
- **Bridge / Builder** — combine with Template Method for staged construction or layered abstraction

Reference: [refactoring.guru/design-patterns/template-method/python](https://refactoring.guru/design-patterns/template-method/python/example)
