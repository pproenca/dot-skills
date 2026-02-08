---
title: Use 8pt Grid for Spacing
impact: HIGH
impactDescription: creates consistent visual rhythm and scalable layouts
tags: layout, spacing, grid, margins, padding
---

## Use 8pt Grid for Spacing

Use multiples of 8 points for all spacing: margins, padding, and gaps. This creates visual rhythm and scales well across device sizes. Use 4pt for minor adjustments only.

**Incorrect (arbitrary spacing breaks rhythm):**

```swift
VStack(spacing: 10) { // Not a multiple of 8
    Text("Title")
        .padding(.horizontal, 15) // Odd number

    Button("Action") { }
        .padding(.top, 22) // Random value
}
```

**Correct (8pt grid spacing):**

```swift
VStack(spacing: 16) { // 2x base unit
    Text("Title")
        .padding(.horizontal, 16) // 2x base unit

    Button("Action") { }
        .padding(.top, 24) // 3x base unit
}

// Common spacing values
VStack(spacing: 8) {  // Tight spacing
    // Related items
}

VStack(spacing: 16) { // Standard spacing
    // Default between sections
}

VStack(spacing: 24) { // Loose spacing
    // Between major sections
}

// Margins from screen edge
.padding(.horizontal, 16) // Standard margin
.padding(.horizontal, 20) // System default for lists
```

**8pt grid scale:**
| Points | Usage |
|--------|-------|
| 4 | Minor adjustments, icon padding |
| 8 | Tight spacing, small gaps |
| 16 | Standard margins, section gaps |
| 24 | Large section spacing |
| 32 | Extra large spacing |
| 40+ | Hero sections, breathing room |

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
