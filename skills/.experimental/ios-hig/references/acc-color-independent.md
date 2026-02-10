---
title: Never Rely on Color Alone
impact: HIGH
impactDescription: 8% of men and 0.5% of women have color vision deficiency — color-only indicators are invisible to 300M+ people worldwide
tags: acc, color, colorblind, indicators
---

## Never Rely on Color Alone

Always supplement color with another indicator (icon, label, pattern) to convey information. Approximately 8% of men have some form of color vision deficiency.

**Incorrect (color as only indicator):**

```swift
// Status only shown by color
Circle()
    .fill(isOnline ? Color.green : Color.red)
    .frame(width: 12, height: 12)

// Error indicated only by red text
TextField("Email", text: $email)
    .foregroundColor(hasError ? .red : .primary)
// Colorblind user can't see the difference

// Chart with color-only legend
ForEach(datasets) { data in
    LineMark(x: .value("X", data.x), y: .value("Y", data.y))
        .foregroundStyle(by: .value("Category", data.category))
}
// Relies on distinguishing colors
```

**Correct (color plus other indicators):**

```swift
// Status with icon and color
HStack(spacing: 4) {
    Image(systemName: isOnline ? "circle.fill" : "circle")
        .foregroundColor(isOnline ? .green : .secondary)
        .font(.caption2)
    Text(isOnline ? "Online" : "Offline")
        .font(.caption)
}

// Error with icon and color
VStack(alignment: .leading) {
    TextField("Email", text: $email)
    if hasError {
        Label("Invalid email format", systemImage: "exclamationmark.circle")
            .font(.caption)
            .foregroundColor(.red)
    }
}

// Form validation with multiple cues
HStack {
    TextField("Password", text: $password)
    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(isValid ? .green : .red)
        .accessibilityLabel(isValid ? "Valid" : "Invalid")
}

// Charts with patterns or labels
ForEach(datasets) { data in
    LineMark(x: .value("X", data.x), y: .value("Y", data.y))
        .foregroundStyle(by: .value("Category", data.category))
        .symbol(by: .value("Category", data.category))
        // Different symbols for each category
}
```

**Supplementary indicators:**
- Icons (checkmark, x, warning)
- Text labels ("Error", "Success")
- Patterns (dashed, dotted lines)
- Shapes (circle, square, triangle)
- Position or size changes

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
