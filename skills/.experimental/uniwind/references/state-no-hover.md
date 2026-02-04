---
title: "Avoid hover: on Native - Use active: Instead"
impact: MEDIUM
impactDescription: prevents unused styles and reduces bundle size
tags: state, hover, active, touch, mobile
---

## Avoid hover: on Native - Use active: Instead

Mobile devices don't have hover states. Use `active:` for touch feedback on native, and `web:hover:` for web targets only.

**Incorrect (hover on native):**

```tsx
// hover: is ignored on iOS/Android
<Pressable className="bg-primary hover:bg-primary/80">
  <Text>Button</Text>
</Pressable>
```

**Correct (platform-appropriate states):**

```tsx
<Pressable className="
  bg-primary
  active:bg-primary/80
  web:hover:bg-primary/80
">
  <Text>Button</Text>
</Pressable>
```

**Complete interactive pattern:**

```tsx
function InteractiveCard() {
  return (
    <Pressable className="
      bg-card rounded-xl p-4
      active:bg-card/90
      active:scale-98
      web:hover:bg-card/95
      web:hover:shadow-lg
      web:cursor-pointer
      focus:ring-2 focus:ring-primary
    ">
      <Text>Interactive content</Text>
    </Pressable>
  )
}
```

**Ignored pseudo-classes on native:**
- `hover:`
- `visited:`
- Web-specific cursor states

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
