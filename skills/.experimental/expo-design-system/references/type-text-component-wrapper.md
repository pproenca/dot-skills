---
title: Route All Text Through One Typed Text Component
impact: HIGH
impactDescription: eliminates raw Text styling at call sites
tags: type, text, component, consistency
---

## Route All Text Through One Typed Text Component

Importing React Native's `Text` directly and styling it inline scatters font family, color, and size across every screen, where each is easy to get subtly wrong. A single `AppText` exposing `variant` and `tone` props makes the type scale the only way to render text and removes the raw style escape hatch.

**Incorrect (raw Text styled ad hoc):**

```typescript
import { Text } from 'react-native'

<Text style={{ fontSize: 16, color: '#374151', fontFamily: 'Inter' }}>Notes</Text>
// fontFamily, color, and size are repeated and drift per screen.
```

**Correct (one AppText driven by variant and tone):**

```typescript
type AppTextProps = Omit<TextProps, 'style'> & {
  variant?: 'title' | 'body' | 'caption'
  tone?: 'default' | 'muted' | 'danger'
}

const styles = StyleSheet.create((theme) => ({
  text: {
    variants: {
      variant: { title: theme.typography.titleL, body: theme.typography.body,
                 caption: theme.typography.caption },
      tone: { default: { color: theme.colors.textPrimary },
              muted: { color: theme.colors.textMuted },
              danger: { color: theme.colors.danger } },
    },
  },
}))

function AppText({ variant = 'body', tone = 'default', ...props }: AppTextProps) {
  styles.useVariants({ variant, tone })
  return <Text style={styles.text} {...props} />
}

<AppText variant="title">Treatment notes</AppText>
```

Reference: [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
