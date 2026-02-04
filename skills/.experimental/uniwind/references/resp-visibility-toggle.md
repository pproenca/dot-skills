---
title: Use hidden/flex for Responsive Visibility
impact: HIGH
impactDescription: cleanly shows/hides content across breakpoints
tags: resp, visibility, hidden, conditional
---

## Use hidden/flex for Responsive Visibility

Toggle element visibility across breakpoints using `hidden` and display utilities. This is cleaner than conditional rendering.

**Incorrect (JavaScript conditional rendering):**

```tsx
function Header() {
  const isDesktop = useMediaQuery('(min-width: 1024px)')

  return (
    <View>
      {isDesktop ? <DesktopNav /> : <MobileMenu />}
    </View>
  )
}
```

**Correct (CSS visibility toggle):**

```tsx
function Header() {
  return (
    <View className="flex-row items-center justify-between">
      {/* Mobile menu - visible on mobile, hidden on desktop */}
      <Pressable className="flex lg:hidden">
        <MenuIcon />
      </Pressable>

      {/* Desktop nav - hidden on mobile, visible on desktop */}
      <View className="hidden lg:flex flex-row gap-4">
        <NavLink>Home</NavLink>
        <NavLink>About</NavLink>
        <NavLink>Contact</NavLink>
      </View>
    </View>
  )
}
```

**Common patterns:**

```tsx
// Show only on mobile
<View className="flex sm:hidden" />

// Show only on tablet and up
<View className="hidden sm:flex" />

// Show only on desktop
<View className="hidden lg:flex" />
```

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)
