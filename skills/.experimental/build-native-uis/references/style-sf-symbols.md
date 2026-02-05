---
title: Use SF Symbols for Platform-Consistent Icons
impact: HIGH
impactDescription: 4,000+ icons that scale with Dynamic Type and match system UI
tags: style, icons, sf-symbols, accessibility, dynamic-type
---

## Use SF Symbols for Platform-Consistent Icons

Custom PNG assets require multiple resolution variants, do not scale with Dynamic Type, and look out of place next to native UI elements. SF Symbols integrate seamlessly with San Francisco, the system font, automatically matching text weight, size, and accessibility settings without additional asset management.

**Incorrect (custom image assets that do not scale with text):**

```swift
struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image("custom-gear-icon") // requires 1x, 2x, 3x assets in asset catalog
                .resizable()
                .frame(width: 24, height: 24)
            Text(title)
                .font(.body)
            Spacer()
            Image("custom-chevron-right")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
    }
}
```

**Correct (SF Symbols that scale with Dynamic Type):**

```swift
struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gearshape.fill") // scales with Dynamic Type automatically
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.accentColor)
            Text(title)
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary) // matches system disclosure indicator style
        }
        .padding(.vertical, 8)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
