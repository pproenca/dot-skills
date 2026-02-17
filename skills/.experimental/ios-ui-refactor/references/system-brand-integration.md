---
title: Map Brand Palette onto iOS Semantic Color Roles
impact: CRITICAL
impactDescription: brand colors applied outside their semantic role erode learned platform conventions — blue used for both links and informational text leads to frequent mis-taps and hesitation
tags: system, color, brand, edson-systems, rams-8, platform-convention
---

## Map Brand Palette onto iOS Semantic Color Roles

A user sees brand blue on a "Delete Account" button and hesitates. Is this destructive or just branded? They have spent years learning that red means danger on iOS, and now your brand has overwritten that instinct with its own palette. The platform already has a semantic color language — red for destructive, green for success, the accent tint for interactive — and your users are fluent in it before they ever open your app. Brand colors are an overlay on that language, not a replacement for it. Map your palette onto the platform's roles so the brand speaks through the system's grammar, not against it.

**Incorrect (brand colors overwrite iOS semantic meanings):**

```swift
struct AccountActions: View {
    var body: some View {
        VStack(spacing: 16) {
            // Brand blue used for informational, non-tappable text
            Text("Account created on Jan 15, 2024")
                .foregroundStyle(Color("brandBlue"))

            // Brand blue also used for a tappable link
            Button("View billing history") {
                // action
            }
            .foregroundStyle(Color("brandBlue"))

            // Brand blue even used for destructive action
            Button("Delete Account") {
                // action
            }
            .foregroundStyle(Color("brandBlue"))

            // Brand green used as a decorative accent, not a success indicator
            HStack {
                Circle()
                    .fill(Color("brandGreen"))
                    .frame(width: 8, height: 8)
                Text("Standard Plan")
                    .foregroundStyle(Color("brandBlue"))
            }
        }
    }
}
```

**Correct (brand palette mapped onto iOS semantic roles):**

```swift
struct AccountActions: View {
    var body: some View {
        VStack(spacing: 16) {
            // Informational text uses secondary — not brand color
            Text("Account created on Jan 15, 2024")
                .foregroundStyle(.secondary)

            // Brand color maps to .tint for interactive elements
            Button("View billing history") {
                // action
            }
            // Inherits .tint from parent or app-level accent color

            // Destructive action uses red — universal iOS convention
            Button("Delete Account", role: .destructive) {
                // action
            }

            // Green dot means active status — matches iOS semantic expectation
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("Active — Standard Plan")
                    .foregroundStyle(.primary)
            }
        }
    }
}

// App-level: set brand color as the global accent
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color("brandAccent"))
        }
    }
}
```

**Brand-to-semantic mapping table:**
| Brand color | iOS semantic role | Applied via |
|---|---|---|
| Brand primary (e.g., blue) | Accent / tint for interactive elements | `.tint(Color("brandAccent"))` at app root |
| Brand dark | Primary text (only if near-black) | Usually unnecessary — `.primary` suffices |
| Brand secondary | Supporting UI, not text color | Decorative accents, illustrations |
| Red (keep system red) | Destructive actions, errors | `Button(role: .destructive)`, `.red` |
| Green (keep system green) | Success, active, online status | `.green` for status indicators |
| Yellow/Orange (keep system) | Warnings, attention needed | `.orange` or `.yellow` for caution |

**The litmus test:** Remove all brand colors and replace them with system defaults. If the app's meaning and hierarchy break, the brand colors were carrying semantic weight they should not own. If the app still makes sense, brand colors were correctly layered on top.

**When NOT to apply:** Apps where the brand IS the product experience (e.g., a streaming service whose red is universally recognized as the primary action color), and the brand color has already been adopted by users as a semantic signal through years of consistent use.

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color), [WWDC21 — Bring accessibility to charts in your app](https://developer.apple.com/videos/play/wwdc2021/10122/)
