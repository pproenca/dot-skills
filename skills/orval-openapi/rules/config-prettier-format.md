---
title: Enable Automatic Code Formatting
impact: HIGH
impactDescription: ensures consistent code style, prevents lint errors
tags: config, prettier, biome, formatting
---

## Enable Automatic Code Formatting

Configure Orval to format generated code with Prettier or Biome. Unformatted generated code causes CI failures and clutters diffs.

**Incorrect (no formatting):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No prettier config - generated code may not match project style
    },
  },
});
```

**Generated code has inconsistent formatting:**
```typescript
export const getUsers=()=>fetch('/users').then(res=>res.json())
```

**Correct (with Prettier):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      prettier: true,  // Use project's .prettierrc
    },
  },
});
```

**Or with explicit config:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      prettier: {
        singleQuote: true,
        trailingComma: 'es5',
        tabWidth: 2,
      },
    },
  },
});
```

**For Biome users:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      biome: true,  // Use project's biome.json
    },
  },
});
```

Reference: [Orval Formatting Options](https://orval.dev/reference/configuration/output)
