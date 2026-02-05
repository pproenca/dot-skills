---
title: Support Dark Mode from Day One
impact: CRITICAL
impactDescription: required for App Store quality, 80%+ users enable Dark Mode
tags: design, dark-mode, colors, images, appearance
---

## Support Dark Mode from Day One

Dark Mode isn't optional. Over 80% of iOS users enable it. Design with both appearances from the start using semantic colors and adaptive assets.

**Incorrect (light-only design):**

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
        .cornerRadius(12)
        .shadow(color: .gray, radius: 4)  // Wrong shadow color
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
        .background(.background.secondary)  // System background
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.1), radius: 4)  // Adaptive shadow
    }
}
```

**Testing both appearances:**

```swift
struct ProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileCard(user: .preview)
                .preferredColorScheme(.light)
            ProfileCard(user: .preview)
                .preferredColorScheme(.dark)
        }
    }
}
```

**Adaptive images in asset catalog:**
1. Add image to Assets.xcassets
2. Select "Appearances" → "Any, Dark"
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

Reference: [Human Interface Guidelines - Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
