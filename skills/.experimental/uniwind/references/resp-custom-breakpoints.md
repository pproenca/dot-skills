---
title: Define Custom Breakpoints with Semantic Names
impact: MEDIUM-HIGH
impactDescription: improves code readability and matches design specifications
tags: resp, breakpoints, custom, semantic
---

## Define Custom Breakpoints with Semantic Names

Override default breakpoints or add new ones using the @theme directive. Use meaningful names like `tablet` instead of arbitrary values.

**Incorrect (using arbitrary values inline):**

```tsx
// Hard to understand what 834px means
<View className="flex-col min-[834px]:flex-row" />
```

**Correct (semantic custom breakpoints):**

```css
/* global.css */
@theme {
  /* Override defaults */
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;

  /* Add semantic names */
  --breakpoint-tablet: 768px;
  --breakpoint-desktop: 1024px;
  --breakpoint-ultrawide: 1920px;
}
```

```tsx
<View className="flex-col tablet:flex-row desktop:gap-8">
  {/* Clear intent: tablet and desktop layouts */}
</View>
```

**Naming conventions:**
- `phone` / `tablet` / `desktop` - Device categories
- `compact` / `regular` / `expanded` - iOS size classes
- `portrait` / `landscape` - Orientation (if needed)

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)
