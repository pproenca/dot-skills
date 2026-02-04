---
title: Use Complete Static Class Names for Build-Time Resolution
impact: MEDIUM-HIGH
impactDescription: enables build-time compilation, 2.5× faster than runtime resolution
tags: perf, static, build-time, compilation
---

## Use Complete Static Class Names for Build-Time Resolution

Uniwind compiles static class names at build time. Dynamic string construction bypasses the compiler, forcing slower runtime resolution.

**Incorrect (dynamic class construction):**

```tsx
function Badge({ color }: { color: 'red' | 'green' | 'blue' }) {
  // Tailwind compiler can't detect these classes!
  return (
    <View className={`bg-${color}-500 p-2 rounded`}>
      <Text className={`text-${color}-900`}>Badge</Text>
    </View>
  )
}
```

**Correct (complete static class names):**

```tsx
const colorStyles = {
  red: 'bg-red-500 text-red-900',
  green: 'bg-green-500 text-green-900',
  blue: 'bg-blue-500 text-blue-900',
} as const

function Badge({ color }: { color: keyof typeof colorStyles }) {
  return (
    <View className={`${colorStyles[color]} p-2 rounded`}>
      <Text>Badge</Text>
    </View>
  )
}
```

**Why this matters:**
- Uniwind precomputes styles at build time
- Dynamic construction forces runtime parsing
- Build-time resolution is ~2.5× faster (81ms vs 197ms)

**Rule of thumb:** If you can grep for the class name in your source code, it will be compiled.

Reference: [Uniwind Performance](https://uniwind.dev/)
