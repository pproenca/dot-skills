---
title: Prefer className Over Inline style Prop
impact: MEDIUM
impactDescription: enables build-time optimization and consistent design tokens
tags: perf, inline-styles, className, consistency
---

## Prefer className Over Inline style Prop

Use className for styling whenever possible. Inline style props bypass build-time optimization and can't use theme variables.

**Incorrect (inline styles):**

```tsx
function Card() {
  return (
    <View
      style={{
        backgroundColor: '#ffffff',
        padding: 16,
        borderRadius: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
      }}
    >
      <Text style={{ fontSize: 18, fontWeight: '600' }}>
        Title
      </Text>
    </View>
  )
}
```

**Correct (className with theme tokens):**

```tsx
function Card() {
  return (
    <View className="bg-card p-4 rounded-xl shadow-md">
      <Text className="text-lg font-semibold">Title</Text>
    </View>
  )
}
```

**When inline styles ARE appropriate:**

```tsx
// Animated values from Reanimated
<Animated.View
  className="bg-card rounded-xl"
  style={animatedStyle}  // useAnimatedStyle result
/>

// Dynamic values from props or calculations
<View
  className="bg-primary"
  style={{ width: calculatedWidth }}
/>
```

**Benefits of className:**
- Theme variable access
- Build-time compilation
- TypeScript autocomplete
- Consistent design tokens
