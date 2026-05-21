---
title: Use Memento to Snapshot State Without Breaking Encapsulation
impact: LOW-MEDIUM
impactDescription: captures restorable snapshots of an object's state through a narrow object so a caretaker (history, transaction log) can store them without seeing private fields, preserves encapsulation that exposing setters would break
tags: behavioral, memento, snapshot, dataclass, undo
---

## Use Memento to Snapshot State Without Breaking Encapsulation

**Pattern intent:** capture an object's internal state so it can be restored later, without exposing that state to the code holding the snapshot. In Python a **frozen dataclass** makes an immutable, opaque memento; the originator produces and consumes it, while the caretaker only stores it.

### Shapes to recognize

- Undo/redo, transactional rollback, checkpoints, or "restore previous version"
- A history list that needs to store past states without understanding them
- Tempted to add public getters/setters for every field just so something else can snapshot it
- "I need to save and restore this object's state without leaking its internals"

### Problem

A text editor supports undo. The history needs prior states, but exposing the editor's content and cursor as public mutable fields so the history can read and rewrite them breaks encapsulation and lets the history corrupt the editor.

### Solution

The originator (editor) produces a memento — a frozen snapshot — and is the only code that can interpret it. A caretaker (history) holds mementos as opaque tokens and hands one back to restore. Encapsulation stays intact because the caretaker never reads the memento's fields.

**Incorrect (caretaker reads/writes the originator's internals):**

```python
class History:
    def save(self, editor):
        # Reaches into private state; adding a field means editing every save site,
        # and the history can now corrupt the editor.
        self.snapshots.append((editor._content, editor._cursor))
    def restore(self, editor):
        editor._content, editor._cursor = self.snapshots.pop()
```

**Correct (frozen memento; originator saves/restores, caretaker only stores):**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class EditorState:                       # the memento: immutable, opaque to the caretaker
    content: str
    cursor: int

class Editor:                            # the originator
    def __init__(self) -> None:
        self._content, self._cursor = "", 0
    def type(self, text: str) -> None:
        self._content += text
        self._cursor = len(self._content)
    def save(self) -> EditorState:
        return EditorState(self._content, self._cursor)
    def restore(self, state: EditorState) -> None:
        self._content, self._cursor = state.content, state.cursor
    def __str__(self) -> str:
        return f"{self._content!r}@{self._cursor}"

class History:                           # the caretaker: stores, never inspects
    def __init__(self) -> None:
        self._states: list[EditorState] = []
    def push(self, state: EditorState) -> None:
        self._states.append(state)
    def pop(self) -> EditorState:
        return self._states.pop()

editor, history = Editor(), History()
editor.type("hello")
history.push(editor.save())
editor.type(" world")
print(editor)
editor.restore(history.pop())
print(editor)
```

**Output:**

```text
'hello world'@11
'hello'@5
```

### When to use

- You need snapshots for undo/redo, rollback, or checkpointing
- You want to restore prior state without exposing the object's internals
- Direct field access for snapshotting would violate encapsulation

### When NOT to use

- The object is small and already immutable — store copies directly
- A full `copy.deepcopy` of the originator is acceptable and simpler than a tailored memento
- State changes constantly and snapshots would be huge — consider command-based undo instead

### Implementation Steps

1. Identify the originator state that must be saved and restored
2. Define a frozen `dataclass` memento holding exactly that state
3. Give the originator a `save()` returning a memento and a `restore(memento)`
4. Give the caretaker a stack/list that stores mementos without reading them
5. For complex graphs, implement `__getstate__`/`__setstate__` or use `copy.deepcopy`

### Pros

- Snapshots without violating the originator's encapsulation
- The caretaker stays simple — it stores opaque tokens
- A frozen dataclass memento can't be tampered with after capture

### Cons

- Many or large mementos consume memory
- Caretakers must manage memento lifetime (when to discard old ones)

### Related Patterns

- **Command** — uses mementos to implement undo; Command represents the action, Memento the state
- **Prototype** — `copy.deepcopy` is a simpler snapshot when encapsulation isn't a concern
- **Iterator** — a memento can capture iteration position to resume later
- **State** — mementos can record which state an object was in

Reference: [refactoring.guru/design-patterns/memento/python](https://refactoring.guru/design-patterns/memento/python/example)
