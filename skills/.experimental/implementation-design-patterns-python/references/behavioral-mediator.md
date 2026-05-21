---
title: Use Mediator to Replace Many-to-Many Coupling with a Hub
impact: MEDIUM
impactDescription: reduces N x N component dependencies to N x 1 by routing all interaction through one mediator, makes components reusable since they no longer reference each other directly
tags: behavioral, mediator, hub, decoupling, coordination
---

## Use Mediator to Replace Many-to-Many Coupling with a Hub

**Pattern intent:** reduce chaotic dependencies between objects by having them communicate through a single mediator instead of referring to each other directly. Components know only the mediator; the mediator holds the coordination logic.

### Shapes to recognize

- UI widgets that each hold references to several others to keep state in sync
- N components wired into an N x N web of direct references
- Coordination logic ("when the checkbox toggles, enable the field, hide the button") smeared across components
- "Every widget references every other widget and I can't reuse any of them in isolation"

### Problem

A form's checkbox enables a text field, which gates a submit button, which updates a label. If each widget references the others directly, they form a tangled mesh: none can be reused alone, and a layout change ripples through every widget.

### Solution

Give each component a reference to one mediator and have it report events there. The mediator holds the coordination rules and drives the other components. Components no longer reference each other — only the hub.

**Incorrect (components reference each other directly — N x N mesh):**

```python
class Checkbox:
    def __init__(self, field, button, label):    # knows three peers
        self.field, self.button, self.label = field, button, label
    def toggle(self):
        self.field.enabled = True
        self.button.enabled = True               # coordination duplicated in every widget
        self.label.text = "ready"
```

**Correct (components talk to one mediator that coordinates them):**

```python
from typing import Protocol

class Mediator(Protocol):
    def notify(self, sender: str, event: str) -> None: ...

class Checkbox:
    def __init__(self, mediator: Mediator) -> None:
        self._mediator = mediator
        self.checked = False
    def toggle(self) -> None:
        self.checked = not self.checked
        self._mediator.notify("checkbox", "toggled")   # report, don't coordinate

class TextField:
    def __init__(self) -> None:
        self.enabled = False

class SubscribeForm:                          # the mediator
    def __init__(self) -> None:
        self.checkbox = Checkbox(self)
        self.email = TextField()
    def notify(self, sender: str, event: str) -> None:
        if sender == "checkbox" and event == "toggled":
            self.email.enabled = self.checkbox.checked   # all rules live here

form = SubscribeForm()
form.checkbox.toggle()
print(form.checkbox.checked, form.email.enabled)
```

**Output:**

```text
True True
```

### When to use

- Components are tightly coupled by mutual references and hard to reuse independently
- Coordination logic is duplicated across components
- Changing one component forces edits in many others

### When NOT to use

- Only two components interact — a direct reference is simpler than a hub
- The mediator would just forward calls with no real coordination — it adds nothing
- Coordination is naturally one-to-many notification — that is **Observer**

### Implementation Steps

1. Identify the tangle of components that reference each other
2. Declare a mediator `Protocol` with a `notify(sender, event)` method
3. Give each component a reference to the mediator and have it report events instead of acting on peers
4. Move all cross-component coordination rules into the mediator's `notify`
5. Construct the components through the mediator so the wiring lives in one place

### Pros

- Decouples components into a hub-and-spoke shape (N x 1 instead of N x N)
- Coordination logic is centralized and easy to change
- Components become reusable in isolation (Single Responsibility)

### Cons

- The mediator can grow into a god object that knows everything
- Centralizing logic can make the hub a complexity magnet

### Related Patterns

- **Observer** — one-to-many notification; Mediator is many-to-many coordination through a hub
- **Facade** — simplifies a subsystem one-directionally; Mediator enables two-way component talk
- **Command** — components may send commands to the mediator rather than raw events
- **Singleton** — a mediator is frequently a single shared instance

Reference: [refactoring.guru/design-patterns/mediator/python](https://refactoring.guru/design-patterns/mediator/python/example)
