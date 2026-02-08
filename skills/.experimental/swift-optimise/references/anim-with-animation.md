---
title: Use withAnimation for State-Driven Transitions
impact: LOW
impactDescription: smooth animations provide spatial context and reduce cognitive load
tags: anim, animation, with-animation, state, transition
---

## Use withAnimation for State-Driven Transitions

Abrupt state changes disorient users because elements appear or disappear without spatial context. Wrapping state mutations in `withAnimation` interpolates between the old and new layout, helping users understand what changed and where to look next.

**Incorrect (abrupt state change with no animation):**

```swift
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack {
                    Text(question)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

**Correct (withAnimation wraps the state change for smooth disclosure):**

```swift
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { // animates the layout change
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
