---
title: Respect Safe Areas for Content Layout
impact: CRITICAL
impactDescription: prevents content clipping by notch, Dynamic Island, home indicator, and system UI
tags: design, safe-areas, layout, notch, home-indicator, dynamic-island
---

## Respect Safe Areas for Content Layout

Safe areas ensure content isn't obscured by the notch, Dynamic Island, home indicator, or status bar. Use `safeAreaInset` modifiers rather than manual padding. Ignore safe areas only intentionally for backgrounds.

**Incorrect (content under system UI):**

```swift
// Content goes under notch/Dynamic Island
VStack {
    Text("Title") // May be under notch
    List { /* content */ }
}
.ignoresSafeArea()

// Manual padding guesses at insets
VStack {
    Text("Title")
        .padding(.top, 44) // Wrong on different devices
}
```

**Correct (respecting safe areas):**

```swift
// Automatic safe area respect (default)
VStack {
    Text("Title")
    List { /* content */ }
}
// No modifier needed - safe areas respected by default

// Background extends, content stays safe
VStack {
    Text("Title")
    List { /* content */ }
}
.background(Color.blue.ignoresSafeArea()) // Background extends
// Content still respects safe area
```

**Extending backgrounds only:**

```swift
struct ProfileHeader: View {
    let user: User

    var body: some View {
        ZStack {
            // Background extends under status bar
            Color.blue
                .ignoresSafeArea(edges: .top)

            // Content respects safe area
            VStack {
                Avatar(url: user.avatarURL)
                Text(user.name)
            }
            .padding(.top, 60)
        }
    }
}
```

**Custom safe area inset:**

```swift
List { /* content */ }
    .safeAreaInset(edge: .bottom) {
        Button("Action") { }
            .frame(maxWidth: .infinity)
    }
```

**Safe area regions:**
- `.top` - Status bar, Dynamic Island
- `.bottom` - Home indicator
- `.leading`, `.trailing` - Rounded corners on iPad
- `.keyboard` - Software keyboard

**Safe area values by device:**
- iPhone with notch: ~47pt top, 34pt bottom
- iPhone with Dynamic Island: ~59pt top, 34pt bottom
- iPhone SE: ~20pt top (status bar only), 0pt bottom

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
