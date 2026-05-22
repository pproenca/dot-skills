---
title: Isolate Platform Differences Behind One Component API
impact: HIGH
impactDescription: eliminates duplicated platform branches scattered across call sites
tags: platform, web, ios, architecture
---

## Isolate Platform Differences Behind One Component API

When a primitive must render differently on web and iOS, scattering `Platform.OS === 'web'` ternaries through call sites duplicates the branch and lets the two platforms drift apart. Resolve the difference once — with a `.ios.tsx` / `.web.tsx` file pair or a single `Platform.select` inside the component — so every feature imports one `<DatePicker>` and never knows there are two implementations.

**Incorrect (every screen re-branches on platform):**

```typescript
{Platform.OS === 'web'
  ? <input type="date" value={value} onChange={(e) => onChange(e.target.value)} />
  : <DateTimePicker value={date} mode="date" onChange={onPickerChange} />}
// The branch is copy-pasted into every form; the web and native inputs drift apart.
```

**Correct (one import, platform resolved by the bundler):**

```typescript
// design-system/DatePicker.web.tsx → renders <input type="date">
// design-system/DatePicker.ios.tsx → renders the native DateTimePicker
// design-system/DatePicker.tsx      → shared prop types only

import { DatePicker } from '@clinic/design-system'

<DatePicker value={date} onChange={onChange} /> // identical call on web and iOS
```

**When NOT to use this pattern:**

- A one-property style difference — prefer a `_web` block in the same StyleSheet over a whole-file split.

Reference: [Platform-specific extensions (React Native)](https://reactnative.dev/docs/platform-specific-code#platform-specific-extensions)
