---
title: Use Constraints for Reusable Matching Logic
impact: CRITICAL
impactDescription: eliminates pattern duplication across rules
tags: pattern, constraints, reuse, dry
---

## Use Constraints for Reusable Matching Logic

Define named constraints for commonly used matching conditions. Reference them with `matches` to keep patterns DRY and maintainable.

**Incorrect (duplicated pattern logic):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Same string type check repeated everywhere
  const stringConcats = root.findAll({
    rule: {
      pattern: "$LEFT + $RIGHT",
      all: [
        { has: { pattern: "$LEFT", any: [
          { kind: "string" },
          { kind: "template_string" }
        ]}},
        { has: { pattern: "$RIGHT", any: [
          { kind: "string" },
          { kind: "template_string" }
        ]}}
      ]
    }
  });
  // Repeated in 10 other rules...
  return null;
};
```

**Correct (reusable constraints):**

```typescript
const transform: Transform<TSX> = (root) => {
  const stringConcats = root.findAll({
    rule: {
      pattern: "$LEFT + $RIGHT"
    },
    constraints: {
      LEFT: { matches: "STRING_LIKE" },
      RIGHT: { matches: "STRING_LIKE" }
    },
    utils: {
      STRING_LIKE: {
        any: [
          { kind: "string" },
          { kind: "template_string" },
          { kind: "string_fragment" }
        ]
      }
    }
  });
  // Reuse STRING_LIKE in other rules
  return null;
};
```

**Constraint patterns:**
- Define common type checks in `utils`
- Reference with `matches: "UTIL_NAME"`
- Use in `constraints` to bind meta variables
- Share across multiple rules in the same transform

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
