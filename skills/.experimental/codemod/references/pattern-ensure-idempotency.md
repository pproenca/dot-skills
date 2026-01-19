---
title: Ensure Patterns Are Idempotent
impact: CRITICAL
impactDescription: prevents infinite transformation loops
tags: pattern, idempotency, safety, reliability
---

## Ensure Patterns Are Idempotent

Patterns should match only pre-transformation code, never post-transformation code. Running a codemod twice should produce the same result as running it once.

**Incorrect (non-idempotent pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern matches both old and new format
  const matches = root.findAll({
    rule: { pattern: "logger($$$ARGS)" }
  });

  const edits = matches.map(match => {
    const args = match.getMultipleMatches("ARGS");
    // Wraps logger() calls with timestamp
    return match.replace(`logger(Date.now(), ${args.map(a => a.text()).join(", ")})`);
  });

  // Running twice: logger(x) -> logger(Date.now(), x) -> logger(Date.now(), Date.now(), x)
  return root.commitEdits(edits);
};
```

**Correct (idempotent pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern specifically excludes already-transformed code
  const matches = root.findAll({
    rule: {
      pattern: "logger($$$ARGS)",
      not: {
        // Skip if first arg is Date.now()
        has: {
          field: "arguments",
          has: {
            kind: "call_expression",
            pattern: "Date.now()"
          }
        }
      }
    }
  });

  const edits = matches.map(match => {
    const args = match.getMultipleMatches("ARGS");
    return match.replace(`logger(Date.now(), ${args.map(a => a.text()).join(", ")})`);
  });

  // Running twice: logger(x) -> logger(Date.now(), x) -> no change
  return root.commitEdits(edits);
};
```

**Idempotency strategies:**
- Use `not` to exclude already-transformed patterns
- Check for sentinel values or markers
- Match specific old API signatures only
- Test by running codemod twice on same input

Reference: [Hypermod Best Practices](https://www.hypermod.io/docs/guides/best-practices)
