---
title: Support Dynamic Type for All Text
impact: MEDIUM-HIGH
impactDescription: 25%+ of users adjust text size settings
tags: acc, dynamic-type, text, scaling, fonts
---

## Support Dynamic Type for All Text

Dynamic Type lets users scale text system-wide. Your app must adapt layouts to accommodate larger text without breaking.

**Incorrect (fixed sizes break at larger settings):**

```swift
struct ProfileHeader: View {
    let user: User

    var body: some View {
        HStack {
            Avatar(url: user.avatarURL)
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.system(size: 18))  // Fixed, won't scale
                Text(user.bio)
                    .font(.system(size: 14))  // Fixed
            }
        }
    }
}
```

**Correct (semantic fonts that scale):**

```swift
struct ProfileHeader: View {
    let user: User
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        layout {
            Avatar(url: user.avatarURL)
                .frame(width: avatarSize, height: avatarSize)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)  // Scales automatically
                Text(user.bio)
                    .font(.subheadline)  // Scales automatically
            }
        }
    }

    // Switch to vertical layout at large text sizes
    @ViewBuilder
    var layout: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) { content }
        } else {
            HStack(spacing: 16) { content }
        }
    }

    var avatarSize: CGFloat {
        typeSize.isAccessibilitySize ? 80 : 60
    }
}
```

**Using ScaledMetric for custom values:**

```swift
struct CustomCard: View {
    @ScaledMetric(relativeTo: .body) var iconSize = 24
    @ScaledMetric(relativeTo: .body) var spacing = 12

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "star")
                .frame(width: iconSize, height: iconSize)
            Text("Favorite")
        }
    }
}
```

**Limiting scaling for specific elements:**

```swift
Text("Price")
    .font(.caption)
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Cap at accessibility1
```

**Testing tip:**

```swift
// Preview at different sizes
#Preview {
    ProfileHeader(user: .preview)
        .environment(\.dynamicTypeSize, .accessibility3)
}
```

Reference: [Supporting Dynamic Type](https://developer.apple.com/documentation/swiftui/dynamictypesize)
