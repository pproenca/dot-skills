---
title: Understand Yoga Layout Engine Differences
impact: MEDIUM
impactDescription: prevents confusion from web CSS assumptions
tags: plat, yoga, layout, flexbox
---

## Understand Yoga Layout Engine Differences

React Native uses Yoga, not browser CSS. Key differences affect layout behavior and available properties.

**Incorrect (assuming web CSS behavior):**

```tsx
// These web CSS patterns don't work in React Native!
<View className="float-left">      {/* No floats */}
<View className="grid">            {/* No CSS grid (work in progress) */}
<View className="hover:bg-red">    {/* No hover on mobile */}
<Text className="cursor-pointer">  {/* No cursor */}
```

**Correct (understanding Yoga defaults):**

```tsx
// All Views are flexbox by default with flexDirection: 'column'
<View className="flex-1">
  <View className="flex-row">      {/* Explicit row layout */}
    <View className="flex-1" />    {/* Flex children */}
    <View className="flex-1" />
  </View>
</View>
```

**Key Yoga differences:**

| Web CSS | Yoga/React Native |
|---------|-------------------|
| `display: block` (default) | `display: flex` (always) |
| `flex-direction: row` | `flex-direction: column` (default) |
| Styles cascade/inherit | Styles don't inherit |
| `em`/`rem` units | Use Uniwind's rem polyfill |
| CSS Grid | Not supported (in progress) |
| `position: fixed` | Use `absolute` + safe areas |

**Unsupported web features:**
- `float`, `clear`
- Pseudo-elements (`::before`, `::after`)
- `hover:`, `visited:` pseudo-classes

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
