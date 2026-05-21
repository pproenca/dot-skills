---
title: Register Themes and Breakpoints in One Typed Module
impact: HIGH
impactDescription: prevents divergent theme definitions and untyped token access
tags: theme, configuration, typescript, setup
---

## Register Themes and Breakpoints in One Typed Module

Calling `StyleSheet.configure` in more than one place lets app and test setups disagree on token values, and skipping module augmentation leaves `theme` typed as `any` so typos compile. A single config module with TypeScript declaration merging gives one source of truth and full autocomplete on every token.

**Incorrect (scattered configure, untyped theme):**

```typescript
// configured in App.tsx, then again in a test helper with different values
StyleSheet.configure({ themes: { light: { colors: { accent: '#0F766E' } } } })

const styles = StyleSheet.create((theme) => ({
  link: { color: theme.colors.acent }, // typo in a token name compiles silently
}))
```

**Correct (one module plus type augmentation):**

```typescript
// design-system/unistyles.ts — imported exactly once at the app entry point
import { StyleSheet } from 'react-native-unistyles'

const lightTheme = { colors: { accent: '#0F766E' } } as const
type AppThemes = { light: typeof lightTheme }

declare module 'react-native-unistyles' {
  export interface UnistylesThemes extends AppThemes {}
}

StyleSheet.configure({ themes: { light: lightTheme }, settings: { initialTheme: 'light' } })
// theme is now fully typed, so theme.colors.acent fails to compile.
```

Reference: [Unistyles TypeScript guide](https://www.unistyl.es/v3/guides/theming/)
