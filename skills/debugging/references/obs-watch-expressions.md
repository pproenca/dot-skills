---
title: Use Watch Expressions for Complex State
impact: HIGH
impactDescription: 3-5× faster state tracking; auto-updates computed values on each step
tags: obs, watch, debugger, expressions, state-tracking
---

## Use Watch Expressions for Complex State

Add watch expressions for computed values and relationships you need to monitor. Watches update automatically as you step through code, revealing exactly when values change unexpectedly.

**Incorrect (manually inspecting each time):**

```javascript
// Bug: Array index sometimes out of bounds
function processItems(items, startIndex) {
  for (let i = startIndex; i < items.length; i++) {
    // Manually type in debug console each step:
    // > items.length
    // > i
    // > i < items.length
    // > items[i]
    // Tedious and error-prone
    processItem(items[i]);
  }
}
```

**Correct (watch expressions):**

```javascript
// Bug: Array index sometimes out of bounds
function processItems(items, startIndex) {
  // Set up watch expressions in debugger:
  // Watch 1: items.length
  // Watch 2: i
  // Watch 3: i < items.length  (the loop condition)
  // Watch 4: items[i]          (current item)
  // Watch 5: items[i + 1]      (lookahead)

  for (let i = startIndex; i < items.length; i++) {
    processItem(items[i]);
    // As you step, watches update automatically:
    // Iteration 0: length=3, i=0, i<length=true, [i]=item0
    // Iteration 1: length=3, i=1, i<length=true, [i]=item1
    // Iteration 2: length=2, i=2, i<length=false <-- length changed!
    // Someone modified items during iteration
  }
}
```

**Useful watch expression patterns:**

```python
# Track object state
watch: user.__dict__
watch: len(items)
watch: type(response)

# Track computed values
watch: total - expected_total
watch: current_time - start_time

# Track relationships
watch: parent.children.includes(child)
watch: request.user.id == response.user_id

# Track conditions
watch: retry_count < max_retries
watch: buffer.length > threshold
```

**Watch expressions vs variables panel:**

| Variables Panel | Watch Expressions |
|-----------------|-------------------|
| Shows all local vars | Shows only what you care about |
| Can be overwhelming | Focused and relevant |
| Raw values only | Computed expressions |
| Updates on frame change | Updates on every step |

**When NOT to use this pattern:**
- Expressions with side effects (will execute every step!)
- Very expensive computations (slows debugging)

Reference: [VS Code Debugging - Watch](https://code.visualstudio.com/docs/debugtest/debugging#_watch)
