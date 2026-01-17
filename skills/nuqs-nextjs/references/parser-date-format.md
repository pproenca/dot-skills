---
title: Select Appropriate Date Parser
impact: CRITICAL
impactDescription: wrong format causes parsing failures and timezone issues
tags: parser, parseAsTimestamp, parseAsIsoDateTime, parseAsIsoDate, dates
---

## Select Appropriate Date Parser

nuqs provides three date parsers with different URL formats and precision. Choose based on your requirements for time precision and URL readability.

**parseAsTimestamp (milliseconds since epoch):**

```tsx
'use client'
import { useQueryState, parseAsTimestamp } from 'nuqs'

export default function EventFilter() {
  const [since, setSince] = useQueryState('since', parseAsTimestamp)
  // URL: ?since=1704067200000
  // State: Date object
  // Pros: Timezone-safe, precise
  // Cons: Not human-readable

  return (
    <input
      type="datetime-local"
      value={since?.toISOString().slice(0, 16) ?? ''}
      onChange={e => setSince(new Date(e.target.value))}
    />
  )
}
```

**parseAsIsoDateTime (full ISO string):**

```tsx
'use client'
import { useQueryState, parseAsIsoDateTime } from 'nuqs'

export default function SchedulePicker() {
  const [datetime, setDatetime] = useQueryState('datetime', parseAsIsoDateTime)
  // URL: ?datetime=2024-01-01T12:00:00.000Z
  // State: Date object
  // Pros: Human-readable with time
  // Cons: Longer URL, timezone in URL

  return (
    <input
      type="datetime-local"
      value={datetime?.toISOString().slice(0, 16) ?? ''}
      onChange={e => setDatetime(new Date(e.target.value))}
    />
  )
}
```

**parseAsIsoDate (date only, no time):**

```tsx
'use client'
import { useQueryState, parseAsIsoDate } from 'nuqs'

export default function DateRangePicker() {
  const [date, setDate] = useQueryState('date', parseAsIsoDate)
  // URL: ?date=2024-01-01
  // State: Date object (time set to 00:00:00 local)
  // Pros: Clean URL, date-only use cases
  // Cons: No time precision

  return (
    <input
      type="date"
      value={date?.toISOString().slice(0, 10) ?? ''}
      onChange={e => setDate(new Date(e.target.value))}
    />
  )
}
```

**When to use each:**

| Parser | URL Format | Use Case |
|--------|------------|----------|
| `parseAsTimestamp` | `1704067200000` | Precise timestamps, API integration |
| `parseAsIsoDateTime` | `2024-01-01T12:00:00.000Z` | Debugging, shareable URLs with time |
| `parseAsIsoDate` | `2024-01-01` | Date pickers, calendar views |

Reference: [nuqs Date Parsers](https://nuqs.dev/docs/parsers)
