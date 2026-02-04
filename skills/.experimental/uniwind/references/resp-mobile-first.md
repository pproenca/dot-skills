---
title: Design Mobile-First with Progressive Enhancement
impact: HIGH
impactDescription: ensures optimal experience on smallest screens first
tags: resp, mobile-first, breakpoints, design
---

## Design Mobile-First with Progressive Enhancement

Uniwind uses mobile-first breakpoints. Unprefixed utilities apply to all screens; prefixed utilities apply at that breakpoint and above.

**Incorrect (desktop-first approach):**

```tsx
// Starting with large screen, then overriding for mobile
<View className="flex-row sm:flex-col p-8 sm:p-4">
  {/* Confusing: base is desktop, overrides for mobile */}
</View>
```

**Correct (mobile-first approach):**

```tsx
// Start mobile, enhance for larger screens
<View className="flex-col sm:flex-row p-4 sm:p-6 lg:p-8">
  {/* Clear: mobile base, progressive enhancement */}
</View>
```

**Mobile-first pattern:**

```tsx
<View className="
  flex-col gap-4          // Mobile: stacked, small gap
  sm:flex-row sm:gap-6    // Tablet: row layout, medium gap
  lg:gap-8                // Desktop: larger gap
">
  <View className="w-full sm:w-1/2 lg:w-1/3">
    {/* Responsive width */}
  </View>
</View>
```

**Default breakpoints:**
- `sm:` - 640px and up
- `md:` - 768px and up
- `lg:` - 1024px and up
- `xl:` - 1280px and up

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)
