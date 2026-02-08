---
title: Support Dynamic Type for All Text
impact: CRITICAL
impactDescription: enables users to read text at their preferred size (25%+ adjust text size)
tags: acc, dynamic-type, font-scaling, readability, text
---

## Support Dynamic Type for All Text

All text must scale with Dynamic Type settings. Users with low vision may need text up to 310% larger. Layouts must accommodate this without truncation. Over 25% of users adjust their text size settings.

**Incorrect (fixed font sizes):**

```swift
// Fixed size ignores user preferences
Text("Hello")
    .font(.system(size: 17))

// Layout breaks at larger sizes
HStack {
    Text("Long label text here")
        .font(.body)
    Spacer()
    Text("Value")
        .lineLimit(1) // Truncates at large sizes
}

// Fixed frame truncates
Text(title)
    .frame(height: 44) // Too small for large text

// Fixed sizes in a profile header
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

**Correct (scales with Dynamic Type):**

```swift
// Use text styles
Text("Hello")
    .font(.body)

// Layout adapts to text size
@ScaledMetric var spacing: CGFloat = 8

VStack(alignment: .leading, spacing: spacing) {
    Text("Long label text here")
        .font(.body)
    Text("Value")
        .font(.body)
        .foregroundColor(.secondary)
}

// Flexible layout with ViewThatFits
ViewThatFits {
    HStack {
        Text(label)
        Spacer()
        Text(value)
    }
    VStack(alignment: .leading) {
        Text(label)
        Text(value)
            .foregroundColor(.secondary)
    }
}

// Adaptive layout switching at accessibility sizes
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

**Scaled image sizes:**

```swift
@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 24

Image(systemName: "star")
    .font(.system(size: iconSize))

// UIKit Dynamic Type
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
label.numberOfLines = 0 // Allow wrapping
```

**Limiting scaling for specific elements:**

```swift
Text("Price")
    .font(.caption)
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Cap at accessibility1
```

**Testing Dynamic Type:**

```swift
// Preview at different sizes
#Preview {
    ProfileHeader(user: .preview)
        .environment(\.dynamicTypeSize, .accessibility3)
}
```

**Accessibility categories:**
- xSmall through xxxLarge (7 sizes)
- AX1 through AX5 (5 more for accessibility)
- Settings -> Accessibility -> Display & Text Size -> Larger Text
- Enable "Larger Accessibility Sizes" and test at largest size (AX5)

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
