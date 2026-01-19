---
title: Verify File Ownership Before Cross-File Edits
impact: HIGH
impactDescription: prevents editing node_modules and external files
tags: semantic, cross-file, safety, validation
---

## Verify File Ownership Before Cross-File Edits

When using semantic analysis for cross-file transformations, verify that target files are within your project before editing. Never modify node_modules or external dependencies.

**Incorrect (editing without ownership check):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const exportedFn = root.find({
    rule: { pattern: "export function deprecatedApi($$$)" }
  });

  if (!exportedFn) return null;

  const refs = exportedFn.field("name")?.references() || [];

  // Blindly edits all references
  for (const fileRef of refs) {
    for (const ref of fileRef.refs) {
      // Might edit node_modules!
      fileRef.root.write(
        fileRef.root.commitEdits([ref.replace("newApi")])
      );
    }
  }

  return null;
};
```

**Correct (ownership verification):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const projectRoot = process.cwd();

  const exportedFn = root.find({
    rule: { pattern: "export function deprecatedApi($$$)" }
  });

  if (!exportedFn) return null;

  const refs = exportedFn.field("name")?.references() || [];

  for (const fileRef of refs) {
    const filePath = fileRef.root.filename();

    // Skip external files
    if (!filePath.startsWith(projectRoot)) {
      console.log(`Skipping external: ${filePath}`);
      continue;
    }

    // Skip node_modules
    if (filePath.includes("node_modules")) {
      console.log(`Skipping dependency: ${filePath}`);
      continue;
    }

    // Skip generated files
    if (filePath.includes("/dist/") || filePath.includes("/build/")) {
      continue;
    }

    // Safe to edit
    for (const ref of fileRef.refs) {
      fileRef.root.write(
        fileRef.root.commitEdits([ref.replace("newApi")])
      );
    }
  }

  return null;
};
```

**File ownership checks:**
- `startsWith(projectRoot)` - within project
- `!includes("node_modules")` - not a dependency
- `!includes("/dist/")` - not generated code
- `!endsWith(".d.ts")` - not type declarations

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)
