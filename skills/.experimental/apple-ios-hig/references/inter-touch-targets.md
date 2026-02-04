---
title: Maintain 44pt Minimum Touch Targets
impact: CRITICAL
impactDescription: ensures tappable elements are accessible to all users
tags: inter, touch-target, accessibility, tap
---

## Maintain 44pt Minimum Touch Targets

All interactive elements must have a minimum touch target of 44x44 points. This is essential for accessibility and reduces tap errors for all users.

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

**Touch target guidelines:**
- Minimum size: 44x44 points
- Minimum spacing between targets: 8pt
- Icons can be smaller visually with larger tap area
- Test with finger, not mouse pointer

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
