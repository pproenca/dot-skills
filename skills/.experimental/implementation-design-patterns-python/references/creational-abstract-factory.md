---
title: Use Abstract Factory to Produce Families of Related Objects
impact: MEDIUM-HIGH
impactDescription: prevents mixing incompatible variants (a macOS checkbox with a Windows button) by guaranteeing every object from one factory belongs to the same family, eliminates parallel `if platform == ...` conditionals at each widget-creation site
tags: creational, abstract-factory, product-family, protocol, runtime-variant
---

## Use Abstract Factory to Produce Families of Related Objects

**Pattern intent:** produce families of related objects (a button *and* a checkbox *and* a menu, all in one visual style) without binding callers to concrete classes, and guarantee the produced objects belong to the same family. In Python a "factory" is just an object whose methods build the parts — a small class implementing a `Protocol`, or even a frozen dataclass bundling constructors.

### Shapes to recognize

- Several products that must vary *together* — Victorian chair + sofa + table, or Windows button + checkbox
- Repeated `if style == "dark": Button = DarkButton; Checkbox = DarkCheckbox` setup at many call sites
- A risk that callers mix families (a light button with a dark checkbox) and nobody notices
- "I switch one config flag and a whole coordinated set of objects must change"

### Problem

A cross-platform UI builds buttons and checkboxes. Pick the platform once, and *every* widget must come from that platform's family. Hard-coding `WinButton()` and `WinCheckbox()` at each site means one missed branch produces a macOS checkbox inside a Windows dialog.

### Solution

Declare a factory `Protocol` with one creator method per product. Each variant is a concrete factory that returns its own family. The app receives one factory and asks it for every part — the family can never be mixed because a single object makes all of them.

**Incorrect (each call site re-decides the variant, so families drift):**

```python
def build_form(platform: str):
    button = WinButton() if platform == "win" else MacButton()
    # A second site forgets the check and hard-codes WinCheckbox() — families now mix.
    checkbox = WinCheckbox()
    return button, checkbox
```

**Correct (one factory makes a coherent family):**

```python
from typing import Protocol

class Button(Protocol):
    def render(self) -> str: ...

class Checkbox(Protocol):
    def render(self) -> str: ...

class GUIFactory(Protocol):
    def create_button(self) -> Button: ...
    def create_checkbox(self) -> Checkbox: ...

class WinButton:
    def render(self) -> str: return "[ Windows button ]"
class WinCheckbox:
    def render(self) -> str: return "[x] Windows checkbox"
class MacButton:
    def render(self) -> str: return "( macOS button )"
class MacCheckbox:
    def render(self) -> str: return "[x] macOS checkbox"

class WinFactory:
    def create_button(self) -> Button: return WinButton()
    def create_checkbox(self) -> Checkbox: return WinCheckbox()

class MacFactory:
    def create_button(self) -> Button: return MacButton()
    def create_checkbox(self) -> Checkbox: return MacCheckbox()

def build_form(factory: GUIFactory) -> str:
    # Receives ONE factory; every part is guaranteed same-family.
    return f"{factory.create_button().render()} {factory.create_checkbox().render()}"

factories = {"win": WinFactory(), "mac": MacFactory()}
print(build_form(factories["mac"]))
```

**Output:**

```text
( macOS button ) [x] macOS checkbox
```

### When to use

- Your code must work with several families of related products and must not mix them
- The concrete family is chosen once (startup, config, OS detection) and reused everywhere
- You want to enforce that a set of products is mutually compatible by construction

### When NOT to use

- There is only one family — the abstraction is pure overhead; build the parts directly
- Products are unrelated and never need to match — a per-product factory (or registry) is simpler
- The family is two trivial values — a frozen `dataclass` of constructors reads more plainly than a class hierarchy

### Implementation Steps

1. Map the product matrix: rows are product types (button, checkbox), columns are variants (win, mac)
2. Declare a `Protocol` for each product type
3. Declare a factory `Protocol` with one `create_*` method per product type
4. Implement one concrete factory per variant, returning that variant's products
5. Resolve the factory once (a `dict` keyed by variant) and thread it through; callers ask it for parts

### Pros

- Products from one factory are guaranteed compatible
- Swapping the whole family is a one-line factory change
- Concrete product classes stay isolated from client code (Single Responsibility, Open/Closed)

### Cons

- Adding a new *product type* changes the factory `Protocol` and every concrete factory
- More indirection than warranted when only one family will ever exist

### Related Patterns

- **Factory Method** — Abstract Factory is a set of factory methods grouped to build a family
- **Builder** — Builder assembles one complex object step by step; Abstract Factory returns families of finished parts
- **Singleton** — the chosen concrete factory is commonly a module-level singleton
- **Prototype** — a factory can clone prototypes instead of instantiating classes

Reference: [refactoring.guru/design-patterns/abstract-factory/python](https://refactoring.guru/design-patterns/abstract-factory/python/example)
