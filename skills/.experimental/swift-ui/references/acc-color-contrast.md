---
title: Maintain Sufficient Color Contrast
impact: MEDIUM-HIGH
impactDescription: 4.5:1 contrast ratio required for WCAG compliance
tags: acc, color, contrast, wcag, visibility
---

## Maintain Sufficient Color Contrast

Text must have sufficient contrast against its background. WCAG requires 4.5:1 for normal text and 3:1 for large text (18pt+).

**Incorrect (insufficient contrast):**

```swift
struct LowContrastLabel: View {
    var body: some View {
        Text("Important info")
            .foregroundColor(.gray)  // ~3:1 ratio on white
            .background(.white)
    }
}

struct SubtleButton: View {
    var body: some View {
        Text("Tap here")
            .foregroundColor(Color(white: 0.7))  // Light gray on white
    }
}
```

**Correct (accessible contrast):**

```swift
struct AccessibleLabel: View {
    var body: some View {
        Text("Important info")
            .foregroundStyle(.secondary)  // System color ensures contrast
    }
}

struct AccessibleButton: View {
    var body: some View {
        Button("Tap here") { }
            .foregroundStyle(.accentColor)  // Designed for contrast
    }
}
```

**System colors automatically handle contrast:**

```swift
// These adapt to light/dark mode with proper contrast
.primary      // Black/White - highest contrast
.secondary    // ~60% opacity - 4.5:1 minimum
.tertiary     // ~30% opacity - use sparingly
.accentColor  // Tinted, always meets contrast

// Be careful with custom colors
Color("CustomGray")  // Must verify contrast in both modes
```

**Testing contrast:**

```swift
// Use Accessibility Inspector to check contrast ratios
// Or online tools like webaim.org/resources/contrastchecker

// Preview in increased contrast mode
#Preview {
    ContentView()
        .environment(\.accessibilityContrast, .increased)
}
```

**Don't rely on color alone:**

```swift
// Wrong: only color indicates error
TextField("Email", text: $email)
    .foregroundColor(hasError ? .red : .primary)

// Right: icon + color + text
VStack(alignment: .leading) {
    TextField("Email", text: $email)
    if hasError {
        Label("Invalid email format", systemImage: "exclamationmark.circle")
            .foregroundStyle(.red)
            .font(.caption)
    }
}
```

Reference: [Human Interface Guidelines - Color and Contrast](https://developer.apple.com/design/human-interface-guidelines/color#Contrast)
