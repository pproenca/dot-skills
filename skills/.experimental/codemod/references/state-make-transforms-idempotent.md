---
title: Make Transforms Idempotent for Safe Reruns
impact: MEDIUM
impactDescription: prevents infinite loops and double-transformation
tags: state, idempotency, safety, rerun
---

## Make Transforms Idempotent for Safe Reruns

Transforms should produce the same result when run multiple times. This allows safe reruns after partial failures.

**Incorrect (non-idempotent transform):**

```typescript
const transform: Transform<TSX> = (root) => {
  const imports = root.findAll({ rule: { kind: "import_statement" } });

  // Adds comment on every run
  const edits = imports.map(imp =>
    imp.replace(`// Migrated\n${imp.text()}`)
  );

  // Run twice:
  // Before:      import x from 'y';
  // After 1:     // Migrated
  //              import x from 'y';
  // After 2:     // Migrated
  //              // Migrated
  //              import x from 'y';

  return root.commitEdits(edits);
};
```

**Correct (idempotent transform):**

```typescript
const transform: Transform<TSX> = (root) => {
  const imports = root.findAll({ rule: { kind: "import_statement" } });

  const edits = imports.flatMap(imp => {
    const text = imp.text();

    // Check if already migrated
    const prev = imp.prev();
    if (prev?.text().includes("// Migrated")) {
      return [];  // Skip already-processed imports
    }

    return [imp.replace(`// Migrated\n${text}`)];
  });

  // Run twice:
  // Before:      import x from 'y';
  // After 1:     // Migrated
  //              import x from 'y';
  // After 2:     (no change)

  return root.commitEdits(edits);
};
```

**Idempotency patterns:**
- Check for transformation markers before applying
- Use `not` in patterns to exclude already-transformed code
- Track processed files in workflow state
- Design transforms to match only pre-transformation patterns

Reference: [Hypermod Best Practices](https://www.hypermod.io/docs/guides/best-practices)
