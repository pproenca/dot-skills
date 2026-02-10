---
title: Maintain 44pt Minimum Touch Targets
impact: CRITICAL
impactDescription: targets below 44pt cause 25%+ tap error rates — motor-impaired users cannot reliably activate small controls
tags: inter, touch-target, accessibility, tap, buttons, tappable
---

## Maintain 44pt Minimum Touch Targets

All interactive elements must have a minimum touch target of 44x44 points. This is essential for accessibility and reduces tap errors for all users, especially those with motor impairments.

**Incorrect (too small touch targets):**

```swift
// Icon button without adequate touch area
Button {
    toggleFavorite()
} label: {
    Image(systemName: "heart")
        .font(.system(size: 16))
}
// Actual tap area may be only 16x16pt

// Small close button
Button {
    dismiss()
} label: {
    Image(systemName: "xmark")
}
.frame(width: 20, height: 20) // Too small

// Tightly spaced buttons
HStack(spacing: 4) {
    Button("A") { }
    Button("B") { }
    Button("C") { }
}
// Easy to tap wrong button
```

**Correct (adequate touch targets):**

```swift
// Explicit minimum frame
Button {
    toggleFavorite()
} label: {
    Image(systemName: "heart")
        .font(.system(size: 20))
}
.frame(minWidth: 44, minHeight: 44)

// Close button with proper size
Button {
    dismiss()
} label: {
    Image(systemName: "xmark.circle.fill")
        .font(.system(size: 24))
        .foregroundColor(.secondary)
}
.frame(width: 44, height: 44)

// contentShape for custom tap areas
Button {
    action()
} label: {
    HStack {
        Image(systemName: "star")
        Text("Favorite")
    }
}
.contentShape(Rectangle())
.frame(minHeight: 44)

// Adequate spacing between targets
HStack(spacing: 16) {
    ForEach(actions) { action in
        Button(action.title) { }
            .frame(minWidth: 44, minHeight: 44)
    }
}
```

**Using contentShape for custom hit areas:**

```swift
struct CompactRow: View {
    let item: Item
    let action: () -> Void

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)  // Visual padding
        .contentShape(Rectangle())  // Entire row is tappable
        .frame(minHeight: 44)  // Minimum height
        .onTapGesture(perform: action)
    }
}
```

**Spacing between targets:**

```swift
struct ActionBar: View {
    var body: some View {
        HStack(spacing: 8) {  // Minimum 8pt between targets
            ForEach(actions) { action in
                Button { } label: {
                    Image(systemName: action.icon)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }
}
```

**Touch target guidelines:**
- Minimum size: 44x44 points
- Minimum spacing between targets: 8pt
- Icons can be smaller visually with larger tap area
- Test with finger, not mouse pointer

**Common violations to avoid:**
- Icon buttons without frame expansion
- Dense toolbars with < 8pt spacing
- Small checkboxes or radio buttons
- Text links without padding

**Testing with accessibility inspector:**

```swift
// Accessibility inspector shows touch target sizes
// Xcode > Open Developer Tool > Accessibility Inspector
```

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
