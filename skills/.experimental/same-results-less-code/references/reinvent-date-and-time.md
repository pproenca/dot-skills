---
title: Stop Hand-Rolling Date and Time Arithmetic
impact: CRITICAL
impactDescription: prevents DST and locale bugs; reduces 20-60 lines of date math to 1-3
tags: reinvent, dates, time, intl
---

## Stop Hand-Rolling Date and Time Arithmetic

Time zones, DST transitions, leap seconds, locale-aware formatting, and "first day of week" all have correct answers in `Intl`, `date-fns`, `Temporal`, `dayjs`, `java.time`, `zoneinfo`, etc. Hand-rolled date logic almost always has at least one of: a DST bug, a UTC/local bug, a "1-indexed month" bug, or a locale-formatting bug. The cost isn't the line count today — it's the recurring bug pattern over years.

**Incorrect (hand-rolled "N days ago" and "format date"):**

```typescript
function daysAgo(n: number): Date {
  const d = new Date();
  d.setTime(d.getTime() - n * 24 * 60 * 60 * 1000);
  // Wrong across DST boundaries — a "day" isn't always 86,400,000 ms.
  return d;
}

function formatDate(d: Date): string {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
  // Locale-blind. Breaks for any non-en-US user.
}
```

**Correct (the library or platform already solved this):**

```typescript
import { subDays, format } from 'date-fns';

const daysAgo = (n: number) => subDays(new Date(), n);
// Handles DST. One line.

const formatDate = (d: Date) =>
  new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(d);
// Honors the user's locale. No month table to maintain.
```

**Other reinventions to catch:**

- "Start of day" via `setHours(0,0,0,0)` → `startOfDay(date)` (handles DST)
- "Difference in business days" via `for` loop → `differenceInBusinessDays`
- "Is this date in the same week?" via day-of-week math → `isSameWeek`
- Custom ISO parsing → `parseISO` or `Date.parse` with explicit format
- Timezone conversion math → `formatInTimeZone` / `Intl` with `timeZone` option

**When NOT to use this pattern:**

- One-off "milliseconds between two timestamps" — a subtraction is fine.
- Performance-critical tight loop where the library allocation dominates — rare; measure first.

Reference: [MDN — Intl.DateTimeFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat)
