---
title: Use System Standard Margins
impact: MEDIUM-HIGH
impactDescription: aligns content with system UI; prevents 4-8pt misalignment with nav/tab bars
tags: layout, margins, padding, alignment
---

## Use System Standard Margins

Use system-provided margins (typically 16-20pt) for content insets. These margins ensure alignment with system UI like navigation bars and tab bars.

**Incorrect (inconsistent or cramped margins):**

```swift
// Too small - feels cramped
List {
    ForEach(items) { item in
        Text(item.name)
    }
}
.listStyle(.plain)
.padding(.horizontal, 8) // Too tight

// Inconsistent with system
VStack {
    Text("Header")
        .padding(.horizontal, 24) // Doesn't match list below
    List { /* content */ }
}
```

**Correct (system-aligned margins):**

```swift
// Lists use system margins automatically
List {
    ForEach(items) { item in
        Text(item.name)
    }
}
// Default insets align with nav bar title

// Custom content matching list margins
VStack(alignment: .leading, spacing: 16) {
    Text("Header")
        .font(.headline)
}
.padding(.horizontal, 20) // Matches list inset
.frame(maxWidth: .infinity, alignment: .leading)

// Using system layout margins
VStack {
    // content
}
.scenePadding(.horizontal)
```

**Standard margin values:**
- List/table content inset: 20pt (default)
- Custom content padding: 16-20pt
- Grouped table section inset: 20pt
- Modal sheet content: 20pt

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
