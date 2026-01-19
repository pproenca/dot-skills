---
title: Combine Patterns with Rule Operators
impact: CRITICAL
impactDescription: enables complex matching without multiple passes
tags: pattern, rules, operators, composition
---

## Combine Patterns with Rule Operators

Use rule operators (`any`, `all`, `not`) to compose complex matching logic in a single pass instead of multiple separate queries.

**Incorrect (multiple passes):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Three separate traversals
  const logCalls = root.findAll({ rule: { pattern: "console.log($$$)" } });
  const warnCalls = root.findAll({ rule: { pattern: "console.warn($$$)" } });
  const errorCalls = root.findAll({ rule: { pattern: "console.error($$$)" } });

  // Combine results manually
  const allCalls = [...logCalls, ...warnCalls, ...errorCalls];
  // 3x traversal time, complex deduplication needed
  return null;
};
```

**Correct (single pass with rule operators):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single traversal with 'any' operator
  const allCalls = root.findAll({
    rule: {
      any: [
        { pattern: "console.log($$$ARGS)" },
        { pattern: "console.warn($$$ARGS)" },
        { pattern: "console.error($$$ARGS)" }
      ]
    }
  });

  // Or use pattern with meta variable
  const consoleCalls = root.findAll({
    rule: {
      pattern: "console.$METHOD($$$ARGS)",
      all: [
        { kind: "call_expression" },
        { not: { pattern: "console.table($$$)" } }
      ]
    }
  });

  return null;
};
```

**Rule operators:**
- `any: [rules]` - matches if ANY rule matches (OR)
- `all: [rules]` - matches if ALL rules match (AND)
- `not: rule` - matches if rule does NOT match
- `matches: "name"` - references named utility rule

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
