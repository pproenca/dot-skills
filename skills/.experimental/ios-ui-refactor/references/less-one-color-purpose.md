---
title: Each Semantic Color Serves Exactly One Purpose
impact: CRITICAL
impactDescription: reusing the same color for links, badges, selection highlights, and decorative accents strips color of meaning — users cannot distinguish tappable from informational, measurably increasing cognitive load and error rates
tags: less, color, tokens, rams-10, segall-minimal, cognitive-load
---

## Each Semantic Color Serves Exactly One Purpose

Color is a language, and like any language, a word that means four things means nothing. When the same blue appears as a tappable link, an informational badge, a selected-row highlight, and a decorative accent, users unconsciously learn that blue is unreliable — they cannot trust it to signal interactivity, so they start tapping everything or nothing. The interface becomes a guessing game. The fix is not adding more colors but giving each color one job and holding it accountable. When blue means "tappable" and only "tappable," users learn the vocabulary in minutes and navigate with confidence. When a green dot always means "active," users stop wondering and start trusting. Each color earns meaning through consistency the way a well-designed icon earns recognition — by never lying.

**Incorrect (one blue color serves four unrelated purposes):**

```swift
struct InboxRow: View {
    let senderName: String
    let subject: String
    let isSelected: Bool
    let hasAttachment: Bool
    let linkText: String

    var body: some View {
        HStack(spacing: 12) {
            // Blue as "selected state"
            Circle()
                .fill(isSelected ? Color.blue : Color.clear)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(senderName)
                    .font(.headline)

                Text(subject)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Blue as "tappable link"
                Button(linkText) {
                    // open link
                }
                .foregroundStyle(Color.blue)
            }

            Spacer()

            if hasAttachment {
                // Blue as "informational badge"
                Image(systemName: "paperclip")
                    .foregroundStyle(Color.blue)
            }
        }
        .padding()
        // Blue as "decorative row accent"
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}
```

**Correct (distinct tokens, each with a single purpose):**

```swift
extension ShapeStyle where Self == Color {
    /// Tappable interactive elements — links, buttons, controls
    static var accentAction: Color { Color.accentColor }

    /// Informational, non-interactive indicators — badges, metadata icons
    static var accentInfo: Color { Color("accentInfo") }

    /// Selected or active state — row highlights, selected tabs
    static var accentSelected: Color { Color("accentSelected") }

    /// Subtle surface for selected state backgrounds
    static var surfaceSelected: Color { Color("surfaceSelected") }
}

struct InboxRow: View {
    let senderName: String
    let subject: String
    let isSelected: Bool
    let hasAttachment: Bool
    let linkText: String

    var body: some View {
        HStack(spacing: 12) {
            // Unread dot uses selection-specific color
            Circle()
                .fill(isSelected ? .accentSelected : Color.clear)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(senderName)
                    .font(.headline)

                Text(subject)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Link uses action-specific color — user learns "this means tappable"
                Button(linkText) {
                    // open link
                }
                .foregroundStyle(.accentAction)
            }

            Spacer()

            if hasAttachment {
                // Metadata icon uses informational color — not tappable
                Image(systemName: "paperclip")
                    .foregroundStyle(.accentInfo)
            }
        }
        .padding()
        // Selected row background uses a dedicated surface token
        .background(isSelected ? .surfaceSelected : Color.clear)
    }
}
```

**Token separation guidelines:**
| Purpose | Token name | Visual differentiation |
|---|---|---|
| Interactive / tappable | `accentAction` | Full saturation of accent color |
| Informational / metadata | `accentInfo` | Desaturated or secondary hue |
| Selected state | `accentSelected` | Distinct from action — often a filled dot or check |
| Decorative surface | `surfaceSelected` | Very low opacity tint, clearly not tappable |
| Destructive | `destructive` | Red — never shared with any non-destructive use |
| Success | `statusSuccess` | Green — reserved for confirmed positive outcomes |

**The audit method:** Search the codebase for every use of `.blue`, `Color.blue`, or the app's accent color. List every use case. If the same color appears in more than one purpose category from the table above, split it into separate tokens. The total number of distinct color tokens should increase, but each token's meaning becomes unambiguous.

**When NOT to apply:** Data visualization contexts where a single hue with varying brightness encodes a continuous range (e.g., a heatmap), and the reuse of one color across multiple "purposes" is the intentional encoding strategy.

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
