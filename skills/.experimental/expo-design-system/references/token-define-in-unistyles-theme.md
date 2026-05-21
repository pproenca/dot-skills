---
title: Define Every Token in the Unistyles Theme
impact: CRITICAL
impactDescription: eliminates duplicated token sources across the app
tags: token, unistyles, theme, single-source
---

## Define Every Token in the Unistyles Theme

When tokens live in both a standalone constants file and the Unistyles theme, the two sources drift apart and components disagree on the same color. Keeping the Unistyles theme as the only token source means every styled component resolves values the same way and theme switching stays automatic.

**Incorrect (two token sources that have already drifted):**

```typescript
// constants/colors.ts — referenced by older screens
export const COLORS = { accent: '#0F766E', danger: '#DC2626' }

// design-system/theme.ts — referenced by newer screens
export const lightTheme = { colors: { accent: '#0EA5A4' } } // accent already differs

const styles = StyleSheet.create(() => ({
  prescriptionBadge: { backgroundColor: COLORS.danger }, // ignores the theme entirely
}))
```

**Correct (one Unistyles theme is the single source):**

```typescript
// design-system/unistyles.ts
import { StyleSheet } from 'react-native-unistyles'

const lightTheme = {
  colors: { accent: '#0F766E', danger: '#DC2626', surface: '#FFFFFF' },
} as const

StyleSheet.configure({ themes: { light: lightTheme }, settings: { initialTheme: 'light' } })

// every component reads from the theme argument, never a parallel constants file
const styles = StyleSheet.create((theme) => ({
  prescriptionBadge: { backgroundColor: theme.colors.danger },
}))
```

Reference: [Unistyles configuration](https://www.unistyl.es/v3/start/configuration/)
