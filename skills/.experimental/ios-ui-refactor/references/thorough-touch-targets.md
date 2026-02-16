---
title: All Interactive Elements at Least 44x44 Points
impact: MEDIUM-HIGH
impactDescription: undersized touch targets cause 15-25% missed taps on mobile — Apple rejects apps that fail their 44pt minimum
tags: thorough, touch-target, accessibility, rams-8, rams-2
---

## All Interactive Elements at Least 44x44 Points

Rams' thoroughness means care and accuracy show respect for the user. A 24pt icon button with no expanded hit area shows disrespect — it forces surgical precision from fingers that cover 44 points. Rams' #2: if the user cannot reliably tap a button, the product has failed at being useful.

**Incorrect (icon button with no hit area expansion):**

```swift
struct MessageToolbar: View {
    var body: some View {
        HStack(spacing: 24) {
            // Each icon is 20x20pt — nearly impossible to tap reliably
            Button(action: { /* attach */ }) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
            }

            Button(action: { /* camera */ }) {
                Image(systemName: "camera")
                    .font(.system(size: 20))
            }

            Button(action: { /* microphone */ }) {
                Image(systemName: "mic")
                    .font(.system(size: 20))
            }
        }
    }
}
```

**Correct (visual size preserved, hit area expanded to 44pt minimum):**

```swift
struct MessageToolbar: View {
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { /* attach */ }) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }

            Button(action: { /* camera */ }) {
                Image(systemName: "camera")
                    .font(.system(size: 20))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }

            Button(action: { /* microphone */ }) {
                Image(systemName: "mic")
                    .font(.system(size: 20))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
        }
    }
}
```

**Alternative — reusable modifier for consistent hit areas:**

```swift
extension View {
    func minimumTapTarget() -> some View {
        self
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

// Usage:
Button(action: { /* dismiss */ }) {
    Image(systemName: "xmark")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.secondary)
        .minimumTapTarget()
}
```

**Common violations to audit:**
| Element | Typical visual size | Needs expansion? |
|---|---|---|
| Navigation bar icon buttons | 22-24pt | Yes — add frame |
| Close/dismiss X button | 16-20pt | Yes — critical target |
| Stepper +/- buttons | 24pt | Yes |
| Checkbox/radio in lists | 20-24pt | Yes |
| Text links in body copy | Height varies | Yes — add vertical padding |
| Full-width buttons | Already 44pt+ | No |

**When NOT to enforce:** Elements that are not directly interactive (decorative icons, status indicators) do not need 44pt frames. SwiftUI `List` rows and `Button` with `.bordered` or `.borderedProminent` style already meet the minimum.

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
