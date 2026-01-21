---
title: Internal Import Paths
impact: MEDIUM
impactDescription: creates clear dependency boundaries between packages
tags: style, imports, paths, modules
---

## Internal Import Paths

Use package imports (e.g., `@base-ui/utils`) for shared utilities. Use relative paths only for files within the same component.

**Incorrect (anti-pattern):**

```typescript
// Deep relative imports crossing package boundaries
import { useControlled } from '../../../../utils/useControlled'
import { warn } from '../../../../../../packages/utils/src/warn'
import { mergeProps } from '../../../shared/mergeProps'
```

**Correct (recommended):**

```typescript
// Package imports for cross-package dependencies
import { useControlled } from '@base-ui/utils/useControlled'
import { warn } from '@base-ui/utils/warn'
import { mergeProps } from '@base-ui/utils/mergeProps'

// Relative imports for same-component files
import { useAccordionRootContext } from '../root/AccordionRootContext'
import { accordionTriggerStateAttributesMapping } from './stateAttributesMapping'
```

**When to use:**
- Always use package imports for utilities and shared code
- Relative imports only within the same component directory tree
- Makes refactoring easier by keeping imports stable
