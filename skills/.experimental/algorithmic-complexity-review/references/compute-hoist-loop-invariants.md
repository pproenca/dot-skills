---
title: Hoist Loop-Invariant Computation Outside the Loop
impact: MEDIUM-HIGH
impactDescription: Eliminates O(n) repeated work per loop body — 2-50× when invariant is heavy
tags: compute, hoisting, loop-invariant, optimization, refactor
---

## Hoist Loop-Invariant Computation Outside the Loop

An expression whose value doesn't depend on the loop variable should be computed once before the loop, not n times inside it. Compilers do this automatically for simple cases (`for i in range(0, len(xs))` typically caches `len(xs)`), but interpreted languages on dynamic expressions often don't — and humans frequently nest expensive operations (regex compilation, list `len()` on changing lists, function-property lookups, environment-variable reads) inside loops without realizing the cost. The fix is mechanical: identify expressions in the loop body whose inputs are all loop-invariant, lift them above the loop, reference the local in the body.

**Incorrect (recomputes invariants per iteration):**

```python
# Bad: re.compile, str.upper on constant string, environment lookup
import os, re
for line in lines:
    pattern = re.compile(r'^\s*(WARN|ERROR)\s+(.*)$')   # compile each iter
    if pattern.match(line.upper()) and os.environ.get('STRICT') == '1':
        ...
# 100,000 lines × ~10μs regex compile = 1 second of compilation alone
```

**Correct (compute once, reference inside):**

```python
import os, re
pattern = re.compile(r'^\s*(WARN|ERROR)\s+(.*)$')
strict = os.environ.get('STRICT') == '1'
for line in lines:
    if pattern.match(line.upper()) and strict:
        ...
# Compile + env lookup happen once
```

**Alternative (loop-invariant DOM in browser code):**

```javascript
// Avoid: each .className access does a string allocation and DOM read
for (const el of nodes) {
  if (el.className.includes('active')) { ... }   // DOM property read
}

// Better: convert to a Set once, drop DOM lookups inside the loop
const active = new Set(document.querySelectorAll('.active'));
for (const el of nodes) {
  if (active.has(el)) { ... }
}
```

**When NOT to use this pattern:**
- When the expression appears to be invariant but actually mutates (subtle aliasing). Verify with a test.
- When hoisting hurts readability and the loop is cold — premature optimization. Profile before refactoring obscure code.

Reference: [Wikipedia — loop-invariant code motion (compiler optimization)](https://en.wikipedia.org/wiki/Loop-invariant_code_motion)
