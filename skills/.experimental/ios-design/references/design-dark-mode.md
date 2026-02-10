---
title: Support Dark Mode from Day One
impact: CRITICAL
impactDescription: prevents invisible text/controls for 80%+ of iOS users who enable Dark Mode
tags: design, dark-mode, colors, images, appearance, theming
---

## Support Dark Mode from Day One

Dark Mode isn't optional. Over 80% of iOS users enable it. Always respect the system appearance setting and design with both appearances from the start using semantic colors and adaptive assets. Never provide an app-specific light/dark toggle unless you have a compelling reason.

**Incorrect (light-only design or ignoring system preference):**

```swift
struct ProfileCard: View {
    let user: User

    var body: some View {
        VStack {
            Image(user.avatar)
            Text(user.name)
                .foregroundColor(.black)  // Invisible in Dark Mode
        }
        .background(Color.white)  // Harsh in Dark Mode
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .gray, radius: 4)  // Wrong shadow color
    }
}

// Forcing light mode - ignores user preference
struct ContentView: View {
    var body: some View {
        VStack {
            // content
        }
        .preferredColorScheme(.light) // Ignores user preference
    }
}
```

**Correct (adaptive design):**

```swift
struct ProfileCard: View {
    let user: User

    var body: some View {
        VStack {
            Image(user.avatar)
            Text(user.name)
                .foregroundStyle(.primary)  // Adapts automatically
        }
        .background(.background.secondary, in: .rect(cornerRadius: 12))
        .shadow(color: .primary.opacity(0.1), radius: 4)  // Adaptive shadow
    }
}
```

**Testing both appearances:**

```swift
#Preview("Light Mode") {
    ProfileCard(user: .preview)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ProfileCard(user: .preview)
        .preferredColorScheme(.dark)
}
```

**Adaptive images in asset catalog:**
1. Add image to Assets.xcassets
2. Select "Appearances" -> "Any, Dark"
3. Provide both light and dark variants

**Responding to appearance changes:**

```swift
struct AdaptiveIcon: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(colorScheme == .dark ? "icon-dark" : "icon-light")
    }
}
```

**Dark mode design considerations:**
- Base colors are dimmer to reduce eye strain
- Elevated surfaces are slightly brighter to show depth
- Avoid pure black (#000000) - use `systemBackground` instead
- Test all custom colors in both modes
- Use vibrancy effects appropriately

Reference: [Human Interface Guidelines - Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
