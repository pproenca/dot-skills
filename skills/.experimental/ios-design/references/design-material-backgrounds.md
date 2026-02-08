---
title: Use Material Backgrounds for Depth
impact: CRITICAL
impactDescription: creates the layered, translucent look of native iOS apps
tags: design, materials, blur, vibrancy, depth
---

## Use Material Backgrounds for Depth

Materials provide the translucent, blurred backgrounds that define iOS's visual language. They create depth and help content stand out while maintaining context.

**Incorrect (solid backgrounds lose context):**

```swift
struct BottomSheet: View {
    let items: [MenuItem]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MenuItemRow(item: item)
            }
        }
        .background(Color.white)  // Solid, no depth
    }
}
```

**Correct (material backgrounds):**

```swift
struct BottomSheet: View {
    let items: [MenuItem]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MenuItemRow(item: item)
            }
        }
        .background(.regularMaterial)  // Translucent, adapts to content behind
    }
}
```

**Material types (thinnest to thickest blur):**

```swift
.ultraThinMaterial  // Subtle blur, most transparent
.thinMaterial       // Light blur
.regularMaterial    // Standard blur (most common)
.thickMaterial      // Heavy blur
.ultraThickMaterial // Maximum blur, most opaque
```

**Common use cases:**

```swift
// Navigation bar style
.toolbarBackground(.regularMaterial, for: .navigationBar)

// Tab bar
.toolbarBackground(.thinMaterial, for: .tabBar)

// Overlay cards
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

// Full-screen overlay
ZStack {
    ContentView()
    Color.clear
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    ModalContent()
}
```

**Vibrancy for text on materials:**

```swift
Text("Vibrant Label")
    .foregroundStyle(.secondary)  // Automatically vibrant on materials
```

Reference: [Human Interface Guidelines - Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
