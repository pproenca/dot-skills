---
title: Use ISO 8601 Date Strings for Date-Only Values
impact: CRITICAL
impactDescription: prevents off-by-day errors from timezone-shifted timestamps
tags: resource, dates, iso-8601, timezone
---

## Use ISO 8601 Date Strings for Date-Only Values

When a value has no meaningful time component — a billing date, a contract effective date, a report period — represent it as an ISO 8601 date string (`"2026-05-20"`), not a Unix timestamp. A timestamp anchors to a specific instant in UTC, which shifts the apparent date when rendered in a different timezone; a date string is timezone-agnostic and represents the calendar date as written, everywhere.

This separation matters because `2026-05-20` viewed from Tokyo is the *same calendar date* `2026-05-20`, but Unix timestamp `1747699200` (midnight UTC on that date) is `2026-05-21 09:00` in Tokyo. Customers see the "wrong" billing date by a day, and every consumer ends up writing the same timezone shim.

**Incorrect (Unix timestamp for a date-only value):**

```json
{
  "id": "in_1234",
  "object": "invoice",
  "period_start": 1747699200,
  "period_end": 1750291200
}
```

```text
// Midnight UTC. In Tokyo (+09:00) the rendered date is the next day.
// Every consumer adds a timezone normalisation step or shows wrong dates.
```

**Incorrect (locale-formatted date):**

```json
{ "due_date": "20/05/2026" }
```

```text
// Ambiguous: DD/MM/YYYY or MM/DD/YYYY? A US consumer reads May 20 as 20 May only if
// they happen to know the API's locale. Silent off-by-month bugs cross borders.
```

**Correct (ISO 8601 date string, no time, no zone):**

```json
{
  "id": "in_1234",
  "object": "invoice",
  "period_start": "2026-05-20",
  "period_end": "2026-06-19"
}
```

```text
// Timezone-agnostic. Sortable lexicographically. Parseable everywhere.
// No timezone shift can change the rendered date.
```

**Decision rule:** ask "if a customer in Tokyo and a customer in New York both see this value, should they see the same calendar date?" If yes → ISO date string. If no (it's an instant in time) → Unix seconds.

For datetimes with a time component, see [`resource-unix-seconds-timestamps`](resource-unix-seconds-timestamps.md). For birth dates, see [`resource-birthdate-hash`](resource-birthdate-hash.md).

Reference: [ISO 8601 dates](https://en.wikipedia.org/wiki/ISO_8601)
