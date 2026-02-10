---
title: Apply Modifiers in Correct Order
impact: HIGH
impactDescription: prevents visual bugs from wrong padding/background/clip ordering
tags: view, modifiers, order, padding, background
---

## Apply Modifiers in Correct Order

Modifier order matters. Each modifier wraps the view in a new view. Padding before background is different from background before padding.

**Incorrect (padding outside background):**

```swift
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .background(Color.blue)  // Background only behind text
            .padding()               // Padding outside background
            .foregroundStyle(.white)
    }
}
// Result: Small blue box with empty padding around it
```

**Correct (padding inside background):**

```swift
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(Color.blue)  // Background includes padding
            .clipShape(.rect(cornerRadius: 8))
    }
}
// Result: Blue rounded rectangle containing padded text
```

**Common modifier ordering:**

```swift
Text("Button")
    // 1. Content modifiers (text styling)
    .font(.headline)
    .foregroundStyle(.white)

    // 2. Layout modifiers (spacing, size)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity)

    // 3. Background/overlay
    .background(Color.accentColor)
    .clipShape(.rect(cornerRadius: 12))

    // 4. Effects (shadow, blur)
    .shadow(radius: 4)

    // 5. Positioning modifiers
    .padding()
```

**Visual debugging tip:**

```swift
Text("Debug")
    .border(.red)      // See text bounds
    .padding()
    .border(.blue)     // See padded bounds
    .background(.gray)
    .border(.green)    // See background bounds
```

**Frame before vs after padding:**

```swift
// Frame then padding - padding is outside the frame
Text("A").frame(width: 100).padding()

// Padding then frame - frame includes padding
Text("B").padding().frame(width: 100)
```

Reference: [8 Common SwiftUI Mistakes](https://www.hackingwithswift.com/articles/224/common-swiftui-mistakes-and-how-to-fix-them)
