---
title: Scale Spacing and Typography Responsively
impact: MEDIUM-HIGH
impactDescription: creates visually balanced layouts across screen sizes
tags: resp, spacing, typography, scaling
---

## Scale Spacing and Typography Responsively

Adjust spacing, padding, and font sizes based on screen size. Larger screens need more whitespace to avoid cramped layouts.

**Incorrect (fixed spacing on all screens):**

```tsx
// Same tight spacing on phone and tablet
<View className="p-4 gap-4">
  <Text className="text-lg">Title</Text>
  <Text className="text-sm">Description</Text>
</View>
```

**Correct (responsive scaling):**

```tsx
<View className="
  p-4 gap-4          // Phone: compact
  sm:p-6 sm:gap-6    // Tablet: more breathing room
  lg:p-8 lg:gap-8    // Desktop: generous spacing
">
  <Text className="text-lg sm:text-xl lg:text-2xl">
    Title
  </Text>
  <Text className="text-sm sm:text-base">
    Description
  </Text>
</View>
```

**Spacing scale recommendation:**

| Element | Phone | Tablet | Desktop |
|---------|-------|--------|---------|
| Container padding | p-4 | p-6 | p-8 |
| Card padding | p-3 | p-4 | p-6 |
| Section gap | gap-4 | gap-6 | gap-8 |
| List item gap | gap-2 | gap-3 | gap-4 |

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)
