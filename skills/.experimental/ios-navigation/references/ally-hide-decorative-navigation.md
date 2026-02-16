---
title: Hide Decorative Navigation Elements from VoiceOver
impact: MEDIUM
impactDescription: prevents VoiceOver from announcing meaningless chevrons and dividers
tags: ally, voiceover, hidden, decorative
---

## Hide Decorative Navigation Elements from VoiceOver

Decorative elements — chevron indicators, divider lines, background gradients, placeholder images, and ornamental icons — add visual structure for sighted users but create noise for VoiceOver. Each decorative element is an extra swipe stop that conveys no information. VoiceOver reads `Image(systemName: "chevron.right")` as "chevron.right" which is confusing and meaningless. Hide these elements so VoiceOver focuses exclusively on actionable, informational content.

**Incorrect (decorative elements announced by VoiceOver):**

```swift
struct MenuItemView: View {
    let item: MenuItem
    var body: some View {
        NavigationLink(value: item.route) {
            HStack {
                // BAD: VoiceOver reads "star.fill, Image" — extra swipe stop
                Image(systemName: item.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 28)
                Text(item.title)
                Spacer()
                // BAD: VoiceOver reads "chevron.right, Image" — redundant
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SectionDividerView: View {
    var body: some View {
        // BAD: VoiceOver stops and reads nothing useful
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
            Image(systemName: "circle.fill").font(.system(size: 4))
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
        }
        .padding(.vertical, 8)
    }
}
```

**Correct (decorative elements hidden from VoiceOver):**

```swift
@Equatable
struct MenuItemView: View {
    let item: MenuItem
    var body: some View {
        NavigationLink(value: item.route) {
            HStack {
                Image(systemName: item.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                Text(item.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
        }
        // VoiceOver: "Favorites, Button" — one swipe, all info
    }
}

@Equatable
struct SectionDividerView: View {
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
            Image(systemName: "circle.fill").font(.system(size: 4))
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
        }
        .padding(.vertical, 8)
        .accessibilityHidden(true)
    }
}

// Exception: meaningful icons need labels, not hiding
@Equatable
struct StatusBadge: View {
    let isOnline: Bool
    var body: some View {
        Circle()
            .fill(isOnline ? .green : .gray)
            .frame(width: 10, height: 10)
            .accessibilityLabel(isOnline ? "Online" : "Offline")
    }
}
```
