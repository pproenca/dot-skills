---
title: Limit Breakpoints to 3-5 for Maintainability
impact: HIGH
impactDescription: reduces complexity and testing burden
tags: resp, breakpoints, maintainability, simplicity
---

## Limit Breakpoints to 3-5 for Maintainability

Using too many breakpoints creates complex, hard-to-test layouts. Focus on 3-5 key breakpoints that match your target devices.

**Incorrect (too many breakpoints):**

```tsx
<Text className="
  text-xs
  xs:text-sm
  sm:text-base
  md:text-lg
  lg:text-xl
  xl:text-2xl
  2xl:text-3xl
">
  {/* 7 breakpoints - hard to maintain and test */}
</Text>
```

**Correct (focused breakpoints):**

```tsx
<Text className="
  text-sm           // Mobile phones
  md:text-base      // Tablets
  lg:text-lg        // Desktop/large tablets
">
  {/* 3 breakpoints - clear and testable */}
</Text>
```

**Recommended breakpoint strategy:**

| Breakpoint | Target | Use Case |
|------------|--------|----------|
| (none) | < 640px | Phones |
| `sm:` | 640px+ | Large phones, small tablets |
| `md:` or `lg:` | 768px-1024px | Tablets |
| `xl:` | 1280px+ | Desktop (web) |

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)
