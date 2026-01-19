---
title: Use Relational Patterns for Context
impact: CRITICAL
impactDescription: enables context-aware matching without manual filtering
tags: pattern, relational, inside, has, context
---

## Use Relational Patterns for Context

Relational patterns (`inside`, `has`, `precedes`, `follows`) match nodes based on their structural context. Use them to avoid manual post-filtering.

**Incorrect (manual context filtering):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Find all setState calls
  const setStateCalls = root.findAll({
    rule: { pattern: "this.setState($$$ARGS)" }
  });

  // Manually filter to those inside useEffect
  const inUseEffect = setStateCalls.filter(call => {
    let parent = call.parent();
    while (parent) {
      if (parent.text().includes("useEffect")) return true;
      parent = parent.parent();
    }
    return false;
  });
  // Slow, error-prone, misses edge cases
  return null;
};
```

**Correct (relational pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single query with context requirement
  const setStateInEffect = root.findAll({
    rule: {
      pattern: "this.setState($$$ARGS)",
      inside: {
        kind: "call_expression",
        pattern: "useEffect($$$)"
      }
    }
  });
  // Correct, fast, handles all nesting levels
  return null;
};
```

**Relational operators:**
- `inside: rule` - node is descendant of matching ancestor
- `has: rule` - node has matching descendant
- `precedes: rule` - node appears before sibling
- `follows: rule` - node appears after sibling
- `stopBy: "neighbor" | "end"` - controls search depth

Reference: [ast-grep Relational Patterns](https://ast-grep.github.io/guide/rule-config.html)
