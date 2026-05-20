---
title: Use the native date and time picker
impact: MEDIUM-HIGH
impactDescription: enables the native wheel and calendar pickers
tags: native, datetimepicker, picker, input
---

## Use the native date and time picker

Dates and times are a solved problem on iOS: the system picker handles locale-aware formatting, the calendar and wheel styles, minimum and maximum bounds, and the inline `compact` presentation in iOS 14+. A scroll list of strings or a custom wheel reimplements all of this, gets locale and time zones subtly wrong, and is hard to make accessible. `@react-native-community/datetimepicker` bridges the real `UIDatePicker`.

**Incorrect (custom string list for a date):**

```tsx
import { ScrollView, Pressable, Text } from 'react-native';

// Hand-built list ignores locale formatting, bounds, and the native compact style
function HikeDatePicker({ dates }: { dates: string[] }) {
  return (
    <ScrollView>
      {dates.map((d) => (
        <Pressable key={d} onPress={() => setHikeDate(d)}><Text>{d}</Text></Pressable>
      ))}
    </ScrollView>
  );
}
```

**Correct (native UIDatePicker):**

```tsx
import DateTimePicker from '@react-native-community/datetimepicker';

// System picker: locale-aware, bounded, with the native compact presentation
function HikeDatePicker() {
  return (
    <DateTimePicker
      value={hikeDate}
      mode="date"
      display="compact"
      minimumDate={new Date()}
      onChange={(_, date) => date && setHikeDate(date)}
    />
  );
}
```

Reference: [react-native-datetimepicker](https://github.com/react-native-datetimepicker/datetimepicker)
