---
title: Maintain Minimum Color Contrast Ratios
impact: HIGH
impactDescription: ensures text readability for all users including those with visual impairments
tags: found, contrast, accessibility, wcag
---

## Maintain Minimum Color Contrast Ratios

Text must have sufficient contrast against its background. Follow WCAG guidelines: 4.5:1 for body text, 3:1 for large text (18pt+ regular or 14pt+ bold).

**Incorrect (insufficient contrast):**

```swift
// Light gray text on white - fails contrast
Text("Hard to read")
    .foregroundColor(Color(white: 0.7))
    .background(Color.white)

// Custom accent with poor contrast
Button("Submit") {
    // action
}
.tint(Color(red: 0.6, green: 0.8, blue: 1.0)) // Too light
```

**Correct (sufficient contrast ratios):**

```swift
// Use semantic colors (guaranteed accessible)
Text("Easy to read")
    .foregroundColor(.primary) // 4.5:1+ contrast

// Secondary text still maintains contrast
Text("Supporting info")
    .foregroundColor(.secondary) // Meets 3:1 minimum

// System colors are contrast-optimized
Button("Submit") {
    // action
}
.buttonStyle(.borderedProminent) // System handles contrast
```

**Contrast checking tools:**
- Xcode Accessibility Inspector
- Color Contrast Analyzer
- WebAIM Contrast Checker

**Never rely on color alone:**
```swift
// Bad: Color is only indicator
Text(isError ? "Invalid" : "Valid")
    .foregroundColor(isError ? .red : .green)

// Good: Icon + color + text
Label(isError ? "Invalid input" : "Valid",
      systemImage: isError ? "xmark.circle" : "checkmark.circle")
    .foregroundColor(isError ? .red : .green)
```

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
