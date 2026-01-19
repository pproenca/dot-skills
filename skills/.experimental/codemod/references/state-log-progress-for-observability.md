---
title: Log Progress for Long-Running Migrations
impact: MEDIUM
impactDescription: enables monitoring and debugging of multi-hour migrations
tags: state, logging, observability, progress
---

## Log Progress for Long-Running Migrations

Add progress logging for transforms that process many files. Logs help monitor progress and debug issues.

**Incorrect (silent processing):**

```typescript
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "oldApi($$$ARGS)" }
  });

  const edits = matches.map(m => m.replace("newApi()"));

  return root.commitEdits(edits);
};

// Running on 5000 files:
// ... silence for 30 minutes ...
// No idea if it's working, stuck, or almost done
```

**Correct (progress logging):**

```typescript
const transform: Transform<TSX> = (root, options) => {
  const filename = root.filename();

  // Log file being processed
  console.log(`Processing: ${filename}`);

  const matches = root.findAll({
    rule: { pattern: "oldApi($$$ARGS)" }
  });

  if (matches.length === 0) {
    console.log(`  No matches in ${filename}`);
    return null;
  }

  console.log(`  Found ${matches.length} matches`);

  const edits = matches.map((m, i) => {
    const line = m.range().start.line;
    console.log(`  [${i + 1}/${matches.length}] Line ${line}: ${m.text().slice(0, 50)}...`);
    return m.replace("newApi()");
  });

  console.log(`  Transformed ${edits.length} occurrences`);

  return root.commitEdits(edits);
};

// Output:
// Processing: src/components/Header.tsx
//   Found 3 matches
//   [1/3] Line 15: oldApi(user)...
//   [2/3] Line 28: oldApi(config)...
//   [3/3] Line 42: oldApi()...
//   Transformed 3 occurrences
```

**Logging best practices:**
- Log filename at start of each file
- Log match counts for debugging
- Include line numbers for review
- Use consistent format for parsing
- Consider verbosity flag for detail control

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)
