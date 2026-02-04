---
title: "Use dark: Variant for Dark Mode Styles"
impact: MEDIUM
impactDescription: eliminates 20+ lines of conditional color logic
tags: state, dark-mode, variant, theme
---

## Use dark: Variant for Dark Mode Styles

Use the `dark:` prefix for dark mode overrides. Styles automatically apply based on the active theme.

**Incorrect (manual dark mode logic):**

```tsx
function Card() {
  const colorScheme = useColorScheme()
  const isDark = colorScheme === 'dark'

  return (
    <View className={isDark ? 'bg-gray-800' : 'bg-white'}>
      <Text className={isDark ? 'text-white' : 'text-gray-900'}>
        Content
      </Text>
    </View>
  )
}
```

**Correct (dark: variant):**

```tsx
function Card() {
  return (
    <View className="bg-white dark:bg-gray-800">
      <Text className="text-gray-900 dark:text-white">
        Content
      </Text>
    </View>
  )
}
```

**Better (semantic theme variables):**

```tsx
// Using theme variables instead of explicit dark: overrides
function Card() {
  return (
    <View className="bg-card">
      <Text className="text-foreground">
        Content
      </Text>
    </View>
  )
}
```

**When to use dark: vs theme variables:**

| Use `dark:` | Use theme variables |
|-------------|-------------------|
| One-off overrides | Consistent design system |
| Quick prototyping | Production apps |
| Color exceptions | Standard colors |

Reference: [Uniwind Theming](https://docs.uniwind.dev/theming/custom-themes)
