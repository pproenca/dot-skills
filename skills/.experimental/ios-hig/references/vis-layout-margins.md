---
title: Use Standard Layout Margins and Safe Areas
impact: HIGH
impactDescription: standard 16pt margins match Apple's own apps — custom margins look out of place and break on Dynamic Island / home indicator devices
tags: vis, layout, margins, safe-area, padding, spacing
---

## Use Standard Layout Margins and Safe Areas

Use system layout margins (16pt horizontal on iPhone) and respect safe areas. Content should never extend behind the Dynamic Island, home indicator, or status bar without explicit intent.

**Incorrect (hardcoded margins that ignore safe areas):**

```swift
// Ignores safe area — content hidden behind Dynamic Island
VStack {
    Text("Welcome")
        .padding(.top, 20) // may overlap status bar
    Spacer()
    Button("Continue") { }
        .padding(.bottom, 20) // overlaps home indicator
}
.ignoresSafeArea() // dangerous without intent

// Non-standard margins
Text("Content")
    .padding(.horizontal, 24) // inconsistent with iOS standard 16pt
```

**Correct (standard margins with safe area respect):**

```swift
// Default padding matches iOS layout margins
VStack {
    Text("Welcome")
    Spacer()
    Button("Continue") { }
}
.padding() // 16pt on all sides, respects safe areas automatically

// Explicit safe area handling for edge-to-edge backgrounds
ZStack {
    Color.blue.ignoresSafeArea() // background extends to edges
    VStack {
        Text("Welcome")
            .foregroundStyle(.white)
    }
    .padding() // content stays within safe area
}
```

**Layout conventions:**
- Default horizontal padding: 16pt (`.padding()` handles this)
- List/Form: system handles margins automatically
- Full-bleed images: use `.ignoresSafeArea()` for background only
- Bottom actions: use `.safeAreaInset(edge: .bottom)` for floating buttons

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
