---
title: Use Distinct File Extensions for Generated Code
impact: HIGH
impactDescription: prevents accidental edits, enables gitignore patterns
tags: output, fileExtension, organization, gitignore
---

## Use Distinct File Extensions for Generated Code

Configure a distinct file extension like `.gen.ts` for generated files. This prevents accidental manual edits and enables easy gitignore patterns for CI regeneration strategies.

**Incorrect (default .ts extension):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      // Default .ts extension - indistinguishable from hand-written code
    },
  },
});
```

**Problems:**
- Developers may accidentally edit generated files
- Hard to set up lint/format rules specifically for generated code
- No clear visual indicator in file explorer

**Correct (distinct extension):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      fileExtension: '.gen.ts',
    },
  },
});
```

**Resulting files:**
```plaintext
src/api/endpoints/
├── users.gen.ts
├── orders.gen.ts
└── models.gen.ts
```

**Configure tooling:**

```gitignore
# .gitignore (for CI regeneration strategy)
*.gen.ts
```

```json
// .eslintrc.json
{
  "ignorePatterns": ["*.gen.ts"]
}
```

**When NOT to use this pattern:**
- Small projects where generated code is committed
- When team prefers standard `.ts` extension

Reference: [Orval fileExtension Option](https://orval.dev/reference/configuration/output)
