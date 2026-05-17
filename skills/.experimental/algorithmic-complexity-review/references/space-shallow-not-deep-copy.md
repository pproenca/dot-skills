---
title: Use Shallow Copies (or No Copy) Instead of Deep Clones
impact: MEDIUM
impactDescription: O(size × depth) to O(1) or O(top-level) — 10-100× on nested structures
tags: space, deep-copy, structured-clone, references, immutability
---

## Use Shallow Copies (or No Copy) Instead of Deep Clones

`copy.deepcopy(x)`, `JSON.parse(JSON.stringify(x))`, and `structuredClone(x)` recursively walk the entire object graph allocating every node. That's necessary when you must isolate mutation; it's wasteful when the caller is read-only or only modifies the top level. Default to no copy at all (just pass the reference), shallow copy when you need to mutate the container (`{...obj}`, `[...arr]`, `dict(d)`), and reach for deep copy only when you've identified a specific aliasing bug that needs it. Deep cloning a large nested object on a hot path is a common source of mysterious latency.

**Incorrect (deep clone the world — O(total nodes)):**

```javascript
function recordSnapshot(state) {
  history.push(structuredClone(state));   // deep walks every nested object
}
// state with 10,000 nodes × 100 snapshots = 1,000,000 allocations
```

**Correct (shallow copy at the level you'll mutate):**

```javascript
function updateField(state, key, value) {
  return { ...state, [key]: value };      // copies top-level keys only
}
// state with 10,000 nested nodes → ~50 top-level pointer copies
```

**Alternative (Python — be explicit about copy depth):**

```python
import copy

# Wrong default: deepcopy everywhere "just in case"
fresh = copy.deepcopy(original)        # walks the whole tree

# Right: only what's needed
fresh = original.copy()                # dict/list shallow copy — O(top-level)
fresh = {**original, 'k': new_value}   # update one key, share the rest
```

**When NOT to use this pattern:**
- When you genuinely need an isolated copy you'll mutate deeply — e.g., test fixtures, undo/redo with full divergence. Deep copy is correct.
- When the structure has cycles — `structuredClone` and `copy.deepcopy` handle them; manual shallow copy doesn't.

Reference: [MDN — `structuredClone` is a deep clone (use sparingly)](https://developer.mozilla.org/en-US/docs/Web/API/structuredClone)
