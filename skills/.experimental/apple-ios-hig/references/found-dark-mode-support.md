---
title: Support Dark Mode System-Wide
impact: CRITICAL
impactDescription: respects user system preference for appearance
tags: found, appearance, theming, system-preference
---

## Support Dark Mode System-Wide

Always respect the system appearance setting. Never provide an app-specific light/dark toggle unless you have a compelling reason - users expect their system preference to apply everywhere.

**Incorrect (ignoring system preference):**

```swift
// Forcing light mode
struct ContentView: View {
    var body: some View {
        VStack {
            // content
        }
        .preferredColorScheme(.light) // Ignores user preference
    }
}

// App-specific toggle that fights the system
@AppStorage("darkMode") var darkMode = false
```

**Correct (automatic system adaptation):**

```swift
// Let the system handle it - no explicit colorScheme override
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Adapts automatically")
                .foregroundColor(.primary)
        }
        .background(Color(.systemBackground))
    }
}

// For images that need different versions
Image(systemName: "photo")
    .symbolRenderingMode(.hierarchical)
// OR provide asset variants in asset catalog for light/dark
```

**Dark mode design considerations:**
- Base colors are dimmer to reduce eye strain
- Elevated surfaces are slightly brighter to show depth
- Avoid pure black (#000000) - use `systemBackground` instead
- Test all custom colors in both modes
- Use vibrancy effects appropriately

Reference: [Dark Mode - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
