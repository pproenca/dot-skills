---
title: Use Button with Action Closures
impact: MEDIUM-HIGH
impactDescription: Button handles tap events and provides built-in affordances like highlight and accessibility
tags: input, button, actions, accessibility, tap-gesture
---

## Use Button with Action Closures

Button is SwiftUI's primary interactive control. It provides built-in tap highlighting, accessibility traits, and keyboard support that `onTapGesture` does not. Using `onTapGesture` on a Text makes the element look tappable only through custom styling, offers no VoiceOver button role, and lacks the visual feedback users expect from interactive elements.

**Incorrect (Text with onTapGesture instead of Button):**

```swift
struct SaveFormView: View {
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Save Changes")
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { // no highlight feedback, no accessibility button role
                    isSaved = true
                }

            if isSaved {
                Text("Changes saved!")
            }
        }
    }
}
```

**Correct (using Button with action closure):**

```swift
struct SaveFormView: View {
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 20) {
            Button { // provides tap highlight, accessibility, and keyboard support
                isSaved = true
            } label: {
                Text("Save Changes")
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if isSaved {
                Text("Changes saved!")
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
