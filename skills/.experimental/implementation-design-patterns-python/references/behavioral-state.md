---
title: Use State to Alter Behavior When Internal State Changes
impact: MEDIUM-HIGH
impactDescription: replaces sprawling `if self.status == ...` blocks in every method with polymorphic state objects, eliminates duplicated state checks across methods, makes adding a state one new class instead of editing every method
tags: behavioral, state, state-machine, protocol, polymorphic-transition
---

## Use State to Alter Behavior When Internal State Changes

**Pattern intent:** let an object change its behavior when its internal state changes, as if it changed class. Each state is an object that implements the context's actions for that state and decides the next transition. In Python the states share a `Protocol`; the context delegates to the current one.

### Shapes to recognize

- A class that is really a state machine, with `if self.status == "x"` repeated in every method
- The same status checks duplicated across methods, easy to update inconsistently
- Transitions tangled into business logic
- "Adding a new status means hunting through every method to add another branch"

### Problem

A media player behaves differently when locked, ready, or playing. Encoding this as `if self.status == ...` blocks duplicates the status check in every method, and adding a "buffering" state means editing all of them — a frequent source of inconsistency.

### Solution

Model each state as an object implementing the actions, where each action performs the behavior and sets the context's next state. The context delegates calls to its current state object — no status conditionals anywhere.

**Incorrect (status conditionals duplicated across methods):**

```python
class Player:
    def __init__(self):
        self.status = "ready"
    def press_play(self):
        if self.status == "locked":
            return
        elif self.status == "ready":
            self.status = "playing"
        elif self.status == "playing":   # every other method repeats this ladder
            self.status = "ready"
```

**Correct (polymorphic state objects own behavior and transitions):**

```python
from typing import Protocol

class State(Protocol):
    def press_play(self, player: "Player") -> None: ...

class Locked:
    def press_play(self, player: "Player") -> None:
        print("locked; ignoring")

class Ready:
    def press_play(self, player: "Player") -> None:
        print("playing")
        player.state = Playing()         # the state decides the transition

class Playing:
    def press_play(self, player: "Player") -> None:
        print("pausing")
        player.state = Ready()

class Player:
    def __init__(self) -> None:
        self.state: State = Ready()
    def press_play(self) -> None:
        self.state.press_play(self)      # delegate; no status ladder

player = Player()
player.press_play()
player.press_play()
```

**Output:**

```text
playing
pausing
```

### When to use

- An object behaves differently depending on a state, with many state-dependent methods
- Conditionals on a status field are duplicated across methods
- States and transitions change often enough that a class per state pays off

### When NOT to use

- There are only two states and one or two methods — a boolean and an `if` is clearer
- Transitions are simple and fixed — an `enum` plus a transition `dict` is lighter than state classes
- The states share almost no behavior — separate objects add ceremony for little gain

### Implementation Steps

1. Identify the context and the actions whose behavior depends on state
2. Declare a state `Protocol` with one method per state-dependent action
3. Implement one class per state; each method performs behavior and sets the next state
4. Give the context a `state` field and delegate each action to it
5. For trivial machines, prefer an `enum` with a `dict` of allowed transitions

### Pros

- Open/Closed: a new state is a new class, not edits across every method
- Removes duplicated status conditionals (Single Responsibility per state)
- Transition logic is localized in the states themselves

### Cons

- More classes than a simple conditional for small machines
- Transition logic spread across state classes can be hard to see as a whole

### Related Patterns

- **Strategy** — same composition shape; State objects know each other and self-transition, Strategy objects are independent
- **Bridge** — also delegates to a swapped object, but to vary an implementation dimension
- **Singleton** — stateless state objects are often shared singletons
- **Memento** — can snapshot which state the context is in

Reference: [refactoring.guru/design-patterns/state/python](https://refactoring.guru/design-patterns/state/python/example)
