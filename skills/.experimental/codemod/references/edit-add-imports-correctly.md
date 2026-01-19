---
title: Add Imports at Correct Position
impact: MEDIUM-HIGH
impactDescription: maintains valid module structure
tags: edit, imports, position, module
---

## Add Imports at Correct Position

When adding new imports, insert them at the correct position relative to existing imports. Respect import ordering conventions.

**Incorrect (appending to end):**

```typescript
const transform: Transform<TSX> = (root) => {
  const needsLogger = root.find({
    rule: { pattern: "logger.$METHOD($$$)" }
  });

  if (!needsLogger) return null;

  const source = root.root().text();

  // Appending import at end breaks module structure
  return source + '\nimport { logger } from "utils/logger";';
  // Import appears after code - invalid syntax!
};
```

**Correct (inserting with existing imports):**

```typescript
const transform: Transform<TSX> = (root) => {
  const needsLogger = root.find({
    rule: { pattern: "logger.$METHOD($$$)" }
  });

  if (!needsLogger) return null;

  // Check if import already exists
  const existingImport = root.find({
    rule: { pattern: 'import { logger } from "utils/logger"' }
  });

  if (existingImport) return null;  // Already imported

  // Find last import statement
  const imports = root.findAll({ rule: { kind: "import_statement" } });
  const lastImport = imports[imports.length - 1];

  if (lastImport) {
    // Insert after last import
    const range = lastImport.range();
    const source = root.root().text();
    const before = source.slice(0, range.end);
    const after = source.slice(range.end);

    return before + '\nimport { logger } from "utils/logger";' + after;
  }

  // No imports exist - add at top after any comments/directives
  const firstNode = root.root().children()[0];
  if (firstNode) {
    const range = firstNode.range();
    const source = root.root().text();
    return 'import { logger } from "utils/logger";\n\n' + source;
  }

  return null;
};
```

**Import ordering conventions:**
1. Node built-ins (`fs`, `path`)
2. External packages (`react`, `lodash`)
3. Internal aliases (`@/utils`, `~/lib`)
4. Relative imports (`./`, `../`)

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
