---
title: Use Command to Turn Requests into Stand-Alone Objects
impact: HIGH
impactDescription: enables undo/redo, queueing, and macro recording by reifying requests as callables or small command objects, decouples the invoker (button, shortcut) from the receiver (business logic), eliminates duplicated invocation logic across UI surfaces
tags: behavioral, command, callable, closure, undo-redo
---

## Use Command to Turn Requests into Stand-Alone Objects

**Pattern intent:** turn a request into a stand-alone object carrying everything needed to perform it later — so it can be queued, logged, or undone. In Python a plain **callable or closure** is the lightest command; pair it with an inverse closure when you need undo.

### Shapes to recognize

- The same action triggered from a button, a shortcut, and a menu — invocation logic duplicated each place
- A need for undo/redo, macro recording, deferred execution, or a job queue
- "I want to store an action now and run (or reverse) it later"
- A history stack of operations the user can step back through

### Problem

A text editor exposes "append text" from a toolbar button, a keyboard shortcut, and a script API. Each entry point re-implements the call, and there's no clean way to add undo without scattering the inverse logic everywhere.

### Solution

Capture each action as a command bundling a `do` and its inverse `undo`. An invoker runs commands and records them on a history stack; undo pops and reverses. The invoker never knows what the command does — only that it can be executed and undone.

**Incorrect (invoker calls receiver logic directly; duplicated, no undo):**

```python
class Toolbar:
    def __init__(self, editor):
        self.editor = editor
    def on_click(self, text):
        self.editor.text += text     # the shortcut handler and script API repeat this;
                                     # nothing records it, so undo is impossible

```

**Correct (commands bundle do/undo; a history runs and reverses them):**

```python
from dataclasses import dataclass
from typing import Callable

@dataclass
class Editor:
    text: str = ""

@dataclass
class Command:
    do: Callable[[], None]
    undo: Callable[[], None]

class History:                          # the invoker
    def __init__(self) -> None:
        self._stack: list[Command] = []
    def run(self, cmd: Command) -> None:
        cmd.do()
        self._stack.append(cmd)
    def undo(self) -> None:
        if self._stack:
            self._stack.pop().undo()

editor, history = Editor(), History()

def append(text: str) -> Command:       # a factory closing over the receiver
    before = editor.text
    return Command(do=lambda: setattr(editor, "text", editor.text + text),
                   undo=lambda: setattr(editor, "text", before))

history.run(append("hello "))
history.run(append("world"))
print(repr(editor.text))
history.undo()
print(repr(editor.text))
```

**Output:**

```text
'hello world'
'hello '
```

### When to use

- You need undo/redo, macro recording, queueing, scheduling, or deferred execution
- You want to decouple the object that triggers an operation from the one that performs it
- The same operation is invoked from several places and you want one definition

### When NOT to use

- The action runs immediately and never needs undo/queueing — a direct call or a plain function is enough
- You only need to pass behavior around — a bare `Callable` or `functools.partial` is the minimal command
- Bundling do/undo adds ceremony that a simple function call would avoid

### Implementation Steps

1. Decide the command contract — a callable, or an object with `do`/`undo`
2. Write factory functions that close over the receiver and capture the inverse state for undo
3. Give the invoker a history stack; push each executed command
4. Implement undo by popping the stack and calling the command's inverse
5. Reuse the same command objects across every UI surface and the script API

### Pros

- Decouples invoker from receiver (Single Responsibility)
- Enables undo/redo, queues, logging, and macros by treating actions as data
- New commands arrive without changing the invoker (Open/Closed)

### Cons

- Adds a layer between caller and action
- Capturing correct undo state can be subtle (snapshot before, not after)

### Related Patterns

- **Memento** — stores the state a command needs to undo itself
- **Chain of Responsibility** — handlers can be commands routed through a chain
- **Strategy** — both wrap behavior; Command represents a request, Strategy an interchangeable algorithm
- **Observer** — commands are often dispatched in response to observed events

Reference: [refactoring.guru/design-patterns/command/python](https://refactoring.guru/design-patterns/command/python/example)
