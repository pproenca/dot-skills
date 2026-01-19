---
title: Avoid Overly Generic Patterns
impact: CRITICAL
impactDescription: reduces matching time from minutes to seconds
tags: pattern, performance, specificity, optimization
---

## Avoid Overly Generic Patterns

Generic patterns match too many nodes, causing performance degradation and false positives. Add constraints to narrow the search space.

**Incorrect (too generic):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Matches EVERY function call in the codebase
  const matches = root.findAll({
    rule: { pattern: "$FN($$$ARGS)" }
  });
  // On a 10k file codebase: matches millions of nodes
  // Takes minutes to process

  // Then filters in JS - wasteful
  const consoleCalls = matches.filter(m =>
    m.getMatch("FN")?.text().startsWith("console")
  );
  return null;
};
```

**Correct (specific pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern specifies exact target
  const matches = root.findAll({
    rule: {
      kind: "call_expression",
      pattern: "console.$METHOD($$$ARGS)"
    }
  });
  // Matches only console.* calls
  // 1000x fewer matches, milliseconds to process

  return null;
};
```

**Specificity guidelines:**
- Include literal text where known (object names, method prefixes)
- Add `kind` constraints to limit node types
- Use `inside`/`has` to require structural context
- Avoid standalone `$VAR` patterns without context

Reference: [ast-grep Match Algorithm](https://ast-grep.github.io/advanced/match-algorithm.html)
