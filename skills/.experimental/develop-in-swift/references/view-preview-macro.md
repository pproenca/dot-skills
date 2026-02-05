---
title: Use #Preview for Live Development
impact: HIGH
impactDescription: instant feedback, test multiple configurations, debug visually without running app
tags: view, swiftui, preview, development, iteration, xcode
---

## Use #Preview for Live Development

The `#Preview` macro creates live previews in Xcode's canvas. Use previews to see changes instantly without building and running the full app. Create multiple previews to test different states and configurations.

**Incorrect (no previews):**

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

// No preview - must run app to see changes
```

**Correct (preview for rapid iteration):**

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// Multiple previews for different states
#Preview("Light Mode") {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

// Preview with sample data
#Preview("With User") {
    ProfileView(user: User(name: "Sophie", email: "sophie@example.com"))
}
```

**Preview modes:**
- **Live Mode**: Interactive - tap buttons, scroll lists
- **Selectable Mode**: Click elements to highlight corresponding code
- **Variants**: Test different dynamic type sizes, color schemes

**Tips:**
- Press Option + Command + P to refresh preview
- Pin previews to keep them visible while editing other files
- Use `.previewLayout(.sizeThatFits)` for component-sized previews

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
