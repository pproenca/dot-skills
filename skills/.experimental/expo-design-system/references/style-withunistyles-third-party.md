---
title: Wrap Third-Party Components With withUnistyles
impact: MEDIUM
impactDescription: preserves token theming for external components on theme change
tags: style, unistyles, third-party, theming
---

## Wrap Third-Party Components With withUnistyles

Third-party components (icon sets, charts, maps) take plain prop values like `color`, so hardcoding a hex skips the theme and freezes the value across light and dark. `withUnistyles` maps theme tokens onto those props and re-applies them natively when the theme switches.

**Incorrect (hardcoding a theme value into a third-party prop):**

```typescript
import { Ionicons } from '@expo/vector-icons'

<Ionicons name="calendar" size={24} color="#0F766E" />
// On a theme switch this icon stays teal — it never reads the theme.
```

**Correct (withUnistyles binds props to theme tokens):**

```typescript
import { withUnistyles } from 'react-native-unistyles'
import { Ionicons } from '@expo/vector-icons'

const ThemedIcon = withUnistyles(Ionicons, (theme) => ({
  color: theme.colors.icon,
}))

<ThemedIcon name="calendar" size={24} />
// The icon now follows the theme and updates natively when it switches.
```

Reference: [Unistyles withUnistyles](https://www.unistyl.es/v3/references/with-unistyles/)
