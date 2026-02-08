---
title: Maintain Sufficient Color Contrast
impact: HIGH
impactDescription: ensures text readability for all users including those with visual impairments (WCAG 4.5:1)
tags: acc, color, contrast, wcag, visibility, accessibility
---

## Maintain Sufficient Color Contrast

Text must have sufficient contrast against its background. WCAG requires 4.5:1 for normal text and 3:1 for large text (18pt+ regular or 14pt+ bold).

**Incorrect (insufficient contrast):**

```swift
// Light gray text on white - fails contrast
Text("Hard to read")
    .foregroundColor(Color(white: 0.7))
    .background(Color.white)

struct LowContrastLabel: View {
    var body: some View {
        Text("Important info")
            .foregroundColor(.gray)  // ~3:1 ratio on white
            .background(.white)
    }
}

// Custom accent with poor contrast
Button("Submit") {
    // action
}
.tint(Color(red: 0.6, green: 0.8, blue: 1.0)) // Too light
```

**Correct (accessible contrast):**

```swift
// Use semantic colors (guaranteed accessible)
Text("Easy to read")
    .foregroundColor(.primary) // 4.5:1+ contrast

// Secondary text still maintains contrast
Text("Supporting info")
    .foregroundStyle(.secondary) // System color ensures contrast

// System colors are contrast-optimized
Button("Submit") {
    // action
}
.buttonStyle(.borderedProminent) // System handles contrast

// Accent color designed for contrast
Button("Tap here") { }
    .foregroundStyle(.accentColor) // Designed for contrast
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

**Contrast checking tools:**
- Xcode Accessibility Inspector
- Color Contrast Analyzer
- WebAIM Contrast Checker

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

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
