---
title: Centralize Icons in a Typed Icon Registry
impact: MEDIUM
impactDescription: prevents inconsistent icon glyphs, sizes, and colors
tags: type, icons, registry, consistency
---

## Centralize Icons in a Typed Icon Registry

Importing an icon set directly at each call site lets two "delete" actions use different glyphs, sizes, and colors. A typed registry maps semantic names to a single glyph and renders them at token sizes through one themed component, so a delete icon looks the same everywhere.

**Incorrect (raw icon imports with ad-hoc size and color):**

```typescript
import { Ionicons } from '@expo/vector-icons'

<Ionicons name="trash-outline" size={22} color="#DC2626" />
// elsewhere, a different glyph and color for the same action
<Ionicons name="trash" size={20} color="red" />
// Two delete icons differ in glyph, size, and color across screens.
```

**Correct (a typed registry maps names to one rendering):**

```typescript
import { withUnistyles } from 'react-native-unistyles'
import { Ionicons } from '@expo/vector-icons'

const ICONS = { delete: 'trash-outline', confirm: 'checkmark-circle', calendar: 'calendar' } as const
type IconName = keyof typeof ICONS

const ThemedIonicons = withUnistyles(Ionicons, (theme) => ({ color: theme.colors.icon }))

function Icon({ name, size = 'md' }: { name: IconName; size?: 'sm' | 'md' | 'lg' }) {
  const px = { sm: 16, md: 22, lg: 28 }[size]
  return <ThemedIonicons name={ICONS[name]} size={px} />
}

<Icon name="delete" />
// Every delete icon is the same glyph at a token size, themed via withUnistyles.
```

Reference: [Unistyles withUnistyles](https://www.unistyl.es/v3/references/with-unistyles/)
