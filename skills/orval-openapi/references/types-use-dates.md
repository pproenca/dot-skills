---
title: Enable useDates for Date Type Generation
impact: MEDIUM
impactDescription: enables Date methods (getFullYear, toISOString) without manual parsing
tags: types, dates, typescript, generation
---

## Enable useDates for Date Type Generation

Enable `useDates` to generate TypeScript Date types for date/datetime fields. Without it, all date fields are typed as `string`, losing type safety.

**Incorrect (dates as strings):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // useDates not enabled - dates typed as string
    },
  },
});
```

**Generated type has string dates:**
```typescript
interface User {
  id: string;
  email: string;
  createdAt: string;  // Should be Date
  updatedAt: string;  // Should be Date
}

// Can't use Date methods
user.createdAt.getFullYear();  // TypeScript error: string has no getFullYear
```

**Correct (useDates enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      useDates: true,
    },
  },
});
```

**Generated type has proper Date types:**
```typescript
interface User {
  id: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

// Date methods available
user.createdAt.getFullYear();  // Works!
```

**Important:** You still need runtime conversion in your mutator:

```typescript
// mutator.ts
import { parseISO } from 'date-fns';

// Recursively converts ISO date strings to Date objects
// API returns dates as strings at runtime despite TypeScript types
const convertDates = (obj: unknown): unknown => {
  if (typeof obj !== 'object' || obj === null) return obj;

  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string' && isISODateString(value)) {
      (obj as Record<string, unknown>)[key] = parseISO(value);
    } else if (typeof value === 'object') {
      convertDates(value);
    }
  }
  return obj;
};
```

Reference: [Orval useDates](https://orval.dev/reference/configuration/output)
