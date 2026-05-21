---
title: Virtualize the Appointment Calendar by Day
impact: MEDIUM-HIGH
impactDescription: prevents rendering a full month of time slots at once
tags: domain, calendar, flashlist, virtualization
---

## Virtualize the Appointment Calendar by Day

A month grid rendered eagerly mounts every day times every time slot — over a thousand cells — before the first is visible, so the calendar opens slowly and scrolls sluggishly. Flattening the schedule into a sectioned agenda and virtualizing it with FlashList mounts only the visible days and recycles headers and rows separately.

**Incorrect (eager month grid in a ScrollView):**

```typescript
// 30 days x 48 half-hour slots = ~1440 cells mounted up front
<ScrollView>
  {monthDays.map((day) => (
    <View key={day.iso}>
      {day.slots.map((slot) => <SlotCell key={slot.id} slot={slot} />)}
    </View>
  ))}
</ScrollView>
// Opening the month view mounts every cell and scrolls sluggishly.
```

**Correct (a sectioned, virtualized agenda):**

```typescript
import { FlashList } from '@shopify/flash-list'

// agendaItems is flattened: [{ kind: 'day' }, { kind: 'appointment' }, ...]
<FlashList
  data={agendaItems}
  renderItem={({ item }) =>
    item.kind === 'day' ? <DayHeader date={item.date} /> : <AppointmentRow item={item} />
  }
  keyExtractor={(item) => item.id}
  stickyHeaderIndices={dayHeaderIndices}
  getItemType={(item) => item.kind}
/>
// Only visible days mount; getItemType lets FlashList recycle headers and rows separately.
```

Reference: [FlashList](https://shopify.github.io/flash-list/)
