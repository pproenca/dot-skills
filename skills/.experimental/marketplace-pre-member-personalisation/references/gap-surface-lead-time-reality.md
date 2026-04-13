---
title: Surface Lead-Time Reality for the Visitor's Dates
impact: HIGH
impactDescription: prevents unmatchable-dates disappointment
tags: gap, lead-time, expectations
---

## Surface Lead-Time Reality for the Visitor's Dates

Lead time is the single most-volatile variable in a two-sided trust marketplace — popular destinations in popular months are typically booked three to six months in advance, while off-season or rural stays can often be booked with two weeks notice. Visitors rarely know this when they land, and they plan trips or stays based on implicit assumptions that are wrong for their specific segment. A visitor searching Lisbon for dates three weeks out has effectively already failed, and the honest thing is to surface the lead-time reality for their dates before they pay, routing them either to flexible dates or to alternative destinations where their lead time is viable.

**Incorrect (no lead-time context on date selection):**

```typescript
function DatePicker({ onConfirm }: Props) {
  return (
    <div>
      <Calendar onSelect={onConfirm} />
      <button>Search</button>
    </div>
  )
}
```

**Correct (lead-time warning with specific median booking advance):**

```typescript
async function DatePicker({ destination, onConfirm }: Props) {
  const [dates, setDates] = useState<DateRange | null>(null)
  const leadTime = dates
    ? await analytics.medianLeadTime({ destination, dateRange: dates })
    : null

  const daysUntilStart = dates ? daysBetween(new Date(), dates.start) : null
  const isTight = daysUntilStart !== null && leadTime !== null && daysUntilStart < leadTime.medianDays

  return (
    <div>
      <Calendar onSelect={setDates} />
      {leadTime && dates && (
        <p className={isTight ? "warning" : "muted"}>
          {isTight
            ? `Bookings in ${destination} for ${dates.start.toLocaleDateString()} usually happen ${leadTime.medianDays} days in advance. You have ${daysUntilStart} days — supply will be thin.`
            : `Typical booking lead time in ${destination}: ${leadTime.medianDays} days. You have time.`}
        </p>
      )}
      <button onClick={() => dates && onConfirm(dates)}>Search</button>
    </div>
  )
}
```

Reference: [Alvin Roth — Who Gets What and Why: The New Economics of Matchmaking and Market Design](https://www.hup.harvard.edu/books/9780544291133)
