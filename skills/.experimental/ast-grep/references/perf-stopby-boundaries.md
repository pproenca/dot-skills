---
title: Use StopBy to Limit Search Depth
impact: MEDIUM
impactDescription: reduces tree traversal in relational rules
tags: perf, stopby, relational, optimization
---

## Use StopBy to Limit Search Depth

Relational rules like `inside` and `has` search the entire tree by default. Use `stopBy` to limit search depth and improve performance.

**Incorrect (searches to root):**

```yaml
id: find-nested-await
language: javascript
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    # Searches all the way up the tree - expensive
```

**Correct (bounded search):**

```yaml
id: find-await-in-function
language: javascript
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    stopBy:
      kind: arrow_function  # Don't cross nested functions
```

**StopBy options:**

```yaml
# Stop at immediate parent only
inside:
  kind: block_statement
  stopBy: neighbor

# Stop at end (default - searches entire tree)
inside:
  kind: function_declaration
  stopBy: end

# Stop at specific node type
inside:
  kind: class_declaration
  stopBy:
    kind: function_declaration
```

**Performance impact:**
- `stopBy: neighbor` - O(1), checks parent only
- `stopBy: {kind: X}` - O(depth to X)
- `stopBy: end` - O(tree height), slowest

**Common boundaries:**
- Functions: `stopBy: { any: [{ kind: function_declaration }, { kind: arrow_function }] }`
- Classes: `stopBy: { kind: class_declaration }`
- Blocks: `stopBy: { kind: block_statement }`

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)
