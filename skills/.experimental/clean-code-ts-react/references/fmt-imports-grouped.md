---
title: Group Imports by Source
impact: HIGH
impactDescription: makes dependency provenance scannable at a glance
tags: fmt, imports, structure, scannability
---

## Group Imports by Source

The import block at the top of a file is a dependency map: external packages, internal aliased modules, sibling files. Grouping them — external first, then aliased internal, then relative — and separating groups with blank lines makes that map scannable. Mixing them turns it into noise.

**Incorrect (imports in random arrival order):**

```tsx
import { useCart } from './hooks/useCart';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { useState } from 'react';
import type { Order } from '@/types/order';
import { formatPrice } from './utils';
import { trpc } from '@/lib/trpc';
// Reader can't tell at a glance which deps are external vs internal vs local.
```

**Correct (three groups, blank line between, external → aliased → relative):**

```tsx
import { useState } from 'react';
import { z } from 'zod';

import { Button } from '@/components/ui/button';
import { trpc } from '@/lib/trpc';
import type { Order } from '@/types/order';

import { useCart } from './hooks/useCart';
import { formatPrice } from './utils';
// Reader sees: "two external deps, three project-internal, two local".
// Adding a new dep is obvious — it goes in its group.
```

**When NOT to apply this pattern:**
- Single-import files — one line, nothing to group.
- Build tools or formatters that automatically reorder imports with a different (but consistent) policy — follow the tool rather than fight it.
- Generated files (codegen output, migration files) where the generator owns the import block.

**Why this matters:** The import block is read every time a file is opened. Spending a few blank lines on structure pays back on every read.

Reference: [Clean Code, Chapter 5: Formatting](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [`eslint-plugin-import` order rule](https://github.com/import-js/eslint-plugin-import/blob/main/docs/rules/order.md)
