---
title: Recognize Timezone and Date Bugs
impact: MEDIUM
impactDescription: prevents date calculation errors across timezones
tags: pattern, timezone, datetime, localization
---

## Recognize Timezone and Date Bugs

Date and timezone bugs are subtle and often only manifest for users in certain locations or at certain times. Symptoms: events on wrong day, off-by-one-day errors near midnight, DST transition bugs.

**Incorrect (timezone-unaware date handling):**

```javascript
// Bug 1: Date comparison ignores timezone
function isToday(eventDate) {
  const today = new Date()
  return eventDate.getDate() === today.getDate()  // Fails across timezones
}

// Bug 2: Creating dates from strings
const deadline = new Date('2024-03-15')  // Parsed as UTC midnight
// In US Pacific (UTC-8): March 14th 4pm!

// Bug 3: Storing local time instead of UTC
const createdAt = new Date().toString()  // "Fri Mar 15 2024 10:30:00 GMT-0800"
// Comparing this string across timezones: chaos
```

**Correct (timezone-aware date handling):**

```javascript
// Fixed 1: Compare using date strings
function isToday(eventDate) {
  const today = new Date()
  return eventDate.toISOString().slice(0, 10) === today.toISOString().slice(0, 10)
}

// Fixed 2: Be explicit about timezone
const deadline = new Date('2024-03-15T00:00:00-08:00')  // Pacific midnight
// Or use a date library:
import { parseISO } from 'date-fns'
import { zonedTimeToUtc } from 'date-fns-tz'

// Fixed 3: Store timestamps in UTC
const createdAt = new Date().toISOString()  // "2024-03-15T18:30:00.000Z"
// Or store Unix timestamp
const createdAtUnix = Date.now()  // 1710526200000

// Display in user's local timezone:
const displayTime = new Date(createdAt).toLocaleString('en-US', {
  timeZone: userTimezone
})
```

**Timezone bug prevention:**
- Store all dates in UTC (ISO 8601 or Unix timestamp)
- Convert to local time only for display
- Use date libraries (date-fns, Luxon) for manipulation
- Test with users in multiple timezones
- Test around DST transitions

Reference: [Wikipedia - Falsehoods Programmers Believe About Time](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
