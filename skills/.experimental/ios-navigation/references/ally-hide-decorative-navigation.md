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
                // BAD: VoiceOver reads "star.fill, Image" — meaningless
                // without context. Adds an extra swipe stop.
                Image(systemName: item.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 28)

                Text(item.title)

                Spacer()

                // BAD: VoiceOver reads "chevron.right, Image"
                // NavigationLink already announces "Button" trait,
                // so the chevron is redundant noise.
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SectionDividerView: View {
    var body: some View {
        // BAD: VoiceOver stops on this and reads nothing useful,
        // or reads "dash, dash, dash" for the decorative line.
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.3))
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundColor(.secondary)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(.vertical, 8)
    }
}
```

**Correct (decorative elements hidden from VoiceOver):**

```swift
struct MenuItemView: View {
    let item: MenuItem

    var body: some View {
        NavigationLink(value: item.route) {
            HStack {
                // Decorative icon: hidden from VoiceOver.
                // The item.title already conveys the meaning.
                // If the icon IS meaningful, use .accessibilityLabel instead.
                Image(systemName: item.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                Text(item.title)

                Spacer()

                // Chevron: purely decorative — NavigationLink already
                // announces as a button. No information added.
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
        }
        // VoiceOver now reads: "Favorites, Button" — clean and clear.
        // One swipe, one element, all necessary information.
    }
}

struct SectionDividerView: View {
    var body: some View {
        // Entire decorative divider hidden from VoiceOver.
        // It is visual-only — no semantic meaning to convey.
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.3))
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundColor(.secondary)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(.vertical, 8)
        .accessibilityHidden(true)
    }
}

// Exception: when an icon IS the primary information carrier,
// give it a label instead of hiding it.
struct StatusBadge: View {
    let isOnline: Bool

    var body: some View {
        Circle()
            .fill(isOnline ? .green : .gray)
            .frame(width: 10, height: 10)
            // This icon IS meaningful — label it, don't hide it.
            .accessibilityLabel(isOnline ? "Online" : "Offline")
    }
}
```
