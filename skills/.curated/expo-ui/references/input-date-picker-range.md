---
title: Constrain Selectable Dates with the range Prop
impact: HIGH
impactDescription: prevents invalid date submission — the picker rejects out-of-range taps natively
tags: input, datePicker, range, validation
---

## Constrain Selectable Dates with the range Prop

`DatePicker.range` accepts `{ start?: Date; end?: Date }`. Setting it disables out-of-range dates in the native picker, so the user cannot pick a check-out before check-in or a birthday in the future. Validating the date in JavaScript after the user selects it provides a worse experience — the user has already committed before seeing the error. Use `range` to constrain at the picker level.

**Incorrect (no range — user can select an invalid future check-in):**

```tsx
import { Host, DatePicker } from '@expo/ui/swift-ui';

const [checkIn, setCheckIn] = useState<Date>();

<Host matchContents>
  <DatePicker
    title="Check-in"
    selection={checkIn}
    onDateChange={setCheckIn}
  />
</Host>
```

**Correct (range bounds the selectable interval to the next 12 months):**

```tsx
import { Host, DatePicker } from '@expo/ui/swift-ui';

const [checkIn, setCheckIn] = useState<Date>();
const today = new Date();
const twelveMonthsOut = new Date(today.getFullYear() + 1, today.getMonth(), today.getDate());

<Host matchContents>
  <DatePicker
    title="Check-in"
    selection={checkIn}
    onDateChange={setCheckIn}
    range={{ start: today, end: twelveMonthsOut }}
  />
</Host>
```

**Alternative (open-ended lower bound for birthday — only past dates):**

```tsx
<DatePicker
  title="Date of birth"
  selection={birthday}
  onDateChange={setBirthday}
  range={{ end: new Date() }}
/>
```

Reference: [@expo/ui DatePicker source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/DatePicker/index.tsx)
