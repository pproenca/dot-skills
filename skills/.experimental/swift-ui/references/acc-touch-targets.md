---
title: Ensure Minimum Touch Target Size
impact: MEDIUM-HIGH
impactDescription: Apple requires 44×44pt minimum for accessibility
tags: acc, touch, targets, buttons, tappable
---

## Ensure Minimum Touch Target Size

Apple's HIG requires interactive elements to be at least 44×44 points. Smaller targets are hard to tap, especially for users with motor impairments.

**Incorrect (tiny touch target):**

```swift
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.caption)  // Only ~16pt, too small
        }
    }
}
```

**Correct (expanded touch target):**

```swift
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.body)
                .frame(width: 44, height: 44)  // Minimum touch target
        }
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

Reference: [Human Interface Guidelines - Touch Targets](https://developer.apple.com/design/human-interface-guidelines/accessibility#Touch-targets)
