---
title: Use with Import Attributes Instead of assert
impact: MEDIUM
impactDescription: replaces the assert syntax deprecated for removal in TS 7.0
tags: modern, import-attributes, json-modules, assert
---

## Use with Import Attributes Instead of assert

The import `assert` syntax for typed module imports was renamed to `with` when import attributes reached Stage 3. TypeScript 6.0 deprecates `assert` — including inside dynamic `import()` calls — ahead of its removal in 7.0. The `with` form is the standardized spelling that current runtimes and bundlers understand.

**Incorrect (deprecated assert syntax):**

```typescript
import config from "./config.json" assert { type: "json" }

const data = await import("./data.json", { assert: { type: "json" } })
```

**Correct (with import attributes):**

```typescript
import config from "./config.json" with { type: "json" }

const data = await import("./data.json", { with: { type: "json" } })
```

Reference: [TypeScript 6.0 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html)
