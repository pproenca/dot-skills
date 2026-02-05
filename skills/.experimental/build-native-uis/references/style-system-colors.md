---
title: Use System Colors for Automatic Dark Mode
impact: HIGH
impactDescription: automatic light/dark mode adaptation without conditional logic
tags: style, colors, dark-mode, theming, accessibility
---

## Use System Colors for Automatic Dark Mode

Hardcoded RGB values require manual overrides for every appearance change, creating maintenance burden and accessibility issues. System colors like `Color.primary`, `Color.secondary`, and `Color.accentColor` adapt automatically to light mode, dark mode, and high-contrast settings across all Apple platforms.

**Incorrect (hardcoded RGB colors that break in dark mode):**

```swift
struct ProfileHeader: View {
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.title)
                .foregroundStyle(Color(red: 0.0, green: 0.0, blue: 0.0)) // invisible on dark backgrounds
            Text("Member since 2024")
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
            Divider()
            Button("Edit Profile") {
                // action
            }
            .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding()
        .background(Color(red: 1.0, green: 1.0, blue: 1.0)) // white background, no dark mode support
    }
}
```

**Correct (system colors that adapt to light and dark mode):**

```swift
struct ProfileHeader: View {
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.title)
                .foregroundStyle(.primary) // adapts to light/dark automatically
            Text("Member since 2024")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
            Button("Edit Profile") {
                // action
            }
            .tint(.accentColor)
        }
        .padding()
        .background(Color(.systemBackground)) // adapts to current appearance
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
