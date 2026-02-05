---
title: Respect Safe Areas for Content Layout
impact: CRITICAL
impactDescription: prevents content clipping by notch, home indicator, and system UI
tags: design, safe-areas, layout, notch, home-indicator
---

## Respect Safe Areas for Content Layout

Safe areas ensure content isn't obscured by the notch, Dynamic Island, home indicator, or status bar. Ignore them only intentionally for backgrounds.

**Incorrect (content under system UI):**

```swift
struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    MessageRow(message: message)
                }
            }
            TextField("Message", text: $inputText)
                .padding()
        }
        .ignoresSafeArea()  // Input field hidden under home indicator
    }
}
```

**Correct (respecting safe areas):**

```swift
struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    MessageRow(message: message)
                }
            }
            TextField("Message", text: $inputText)
                .padding()
        }
        // Safe area respected by default
    }
}
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

**Safe area regions:**
- `.top` - Status bar, Dynamic Island
- `.bottom` - Home indicator
- `.leading`, `.trailing` - Rounded corners on iPad
- `.keyboard` - Software keyboard

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
