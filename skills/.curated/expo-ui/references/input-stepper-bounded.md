---
title: Provide min and max on Stepper to Bound the Increment Range
impact: MEDIUM-HIGH
impactDescription: prevents out-of-range values — the + and - buttons disable at the boundaries
tags: input, stepper, min, max, bounds
---

## Provide min and max on Stepper to Bound the Increment Range

`Stepper` has +/− buttons that walk a numeric value by `step`. Without `min` and `max`, the user can freely run the value below zero or above whatever business logic permits — and the buttons stay enabled, falsely promising more room. Setting both bounds lets the native stepper dim the appropriate button at the edge, communicating the limit visually.

**Incorrect (unbounded stepper — guest count can go negative):**

```tsx
import { Host, Stepper } from '@expo/ui/swift-ui';

<Host matchContents>
  <Stepper label="Guests" value={guests} step={1} onValueChange={setGuests} />
</Host>
```

**Correct (min and max set the booking-valid range):**

```tsx
import { Host, Stepper } from '@expo/ui/swift-ui';

<Host matchContents>
  <Stepper
    label="Guests"
    value={guests}
    step={1}
    min={1}
    max={8}
    onValueChange={setGuests}
  />
</Host>
```

Reference: [@expo/ui Stepper source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Stepper/index.tsx)
