---
title: Render Long Lists With FlashList, Not ScrollView
impact: HIGH
impactDescription: prevents mounting every off-screen row at once
tags: perf, flashlist, lists, virtualization
---

## Render Long Lists With FlashList, Not ScrollView

Mapping data inside a `ScrollView` mounts every row up front, so a full day of appointments mounts hundreds of components before the first is visible — spiking memory and time-to-interactive. FlashList virtualizes the list, mounting only what fits on screen and recycling rows as the clinician scrolls.

**Incorrect (map inside a ScrollView):**

```typescript
<ScrollView>
  {appointments.map((a) => <AppointmentRow key={a.id} item={a} />)}
</ScrollView>
// A 300-appointment day mounts 300 rows immediately, spiking memory and TTI.
```

**Correct (FlashList virtualizes to visible rows):**

```typescript
import { FlashList } from '@shopify/flash-list'

<FlashList
  data={appointments}
  renderItem={({ item }) => <AppointmentRow item={item} />}
  keyExtractor={(item) => item.id}
/>
// FlashList mounts only visible rows and recycles them during scroll.
```

Reference: [FlashList](https://shopify.github.io/flash-list/)
