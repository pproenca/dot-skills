---
title: "Use web: Selector for Cross-Platform Apps"
impact: MEDIUM
impactDescription: enables web-specific styles without affecting native
tags: plat, web, cross-platform, expo-web
---

## Use web: Selector for Cross-Platform Apps

For apps targeting both native and web (Expo Web, React Native Web), use `web:` prefix for web-specific styles.

**Incorrect (web styles applying to native):**

```tsx
// cursor and hover apply to native where they do nothing
<Pressable className="cursor-pointer hover:bg-gray-100">
  Click me
</Pressable>
```

**Correct (platform-specific):**

```tsx
<Pressable className="
  active:bg-gray-100
  web:cursor-pointer
  web:hover:bg-gray-100
">
  Click me
</Pressable>
```

**Common web-specific patterns:**

```tsx
// Web hover effects
<View className="web:hover:scale-105 web:transition-transform">
  Hover to scale on web
</View>

// Web-specific layout
<View className="
  flex-col
  web:flex-row
  web:max-w-4xl
  web:mx-auto
">
  Responsive layout
</View>

// Web cursor states
<Pressable className="web:cursor-pointer web:select-none">
  Interactive element
</Pressable>
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
