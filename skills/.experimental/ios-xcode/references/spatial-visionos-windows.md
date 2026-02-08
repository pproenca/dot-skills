---
title: Build visionOS Apps with Windows
impact: MEDIUM
impactDescription: spatial computing entry point, familiar SwiftUI patterns, depth and scale
tags: spatial, visionos, spatial-computing, windows, vision-pro
---

## Build visionOS Apps with Windows

visionOS windows use familiar SwiftUI patterns but exist in 3D space. Add depth with `.offset(z:)` and use glass material backgrounds. Windows are the foundation before volumes and immersive spaces.

**Incorrect (ignoring spatial design):**

```swift
// Don't use flat, opaque backgrounds in visionOS
struct BadVisionView: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
        .background(Color.white)  // Opaque backgrounds look wrong
        .frame(width: 200, height: 100)  // Fixed sizes don't adapt
    }
}
```

**Basic visionOS window:**

```swift
import SwiftUI

@main
struct MyVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, visionOS!")
                .font(.extraLargeTitle)

            Image(systemName: "vision.pro")
                .font(.system(size: 100))
        }
        .padding(50)
    }
}
```

**Adding depth to elements:**

```swift
struct DepthView: View {
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 20) {
            // Elements at different depths
            Text("Background")
                .padding()
                .background(.regularMaterial)

            Text("Foreground")
                .padding()
                .background(.regularMaterial)
                .offset(z: 50)  // Comes toward viewer

            // Interactive depth
            Button("Press Me") {
                isPressed.toggle()
            }
            .offset(z: isPressed ? 100 : 0)
            .animation(.spring, value: isPressed)
        }
    }
}
```

**visionOS considerations:**
- Use glass materials (`.regularMaterial`, `.thickMaterial`)
- Add depth with `.offset(z:)` in points
- Larger touch targets (44pt minimum, 60pt+ recommended)
- Test in Simulator and on device

Reference: [Develop in Swift Tutorials - Add depth to your app](https://developer.apple.com/tutorials/develop-in-swift/add-depth-to-your-app)
