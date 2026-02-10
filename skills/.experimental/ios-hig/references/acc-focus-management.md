---
title: Manage Focus for Assistive Technologies
impact: MEDIUM-HIGH
impactDescription: broken focus order forces VoiceOver users to swipe through every element — proper focus reduces navigation steps by 50-80%
tags: acc, focus, voiceover, keyboard-navigation
---

## Manage Focus for Assistive Technologies

Manage focus order to ensure logical navigation. Focus should move through content in a meaningful sequence, and move to new content when it appears.

**Incorrect (poor focus management):**

```swift
// Modal appears but focus doesn't move
.sheet(isPresented: $showSheet) {
    SheetContent()
}
// VoiceOver user still focused on background

// Logical order broken
VStack {
    Button("Action") { }
    // After action, new content appears above
    if showResult {
        Text("Result here") // Focus doesn't move here
    }
}

// Custom order that doesn't make sense
HStack {
    Text("Step 2")
        .accessibilitySortPriority(1)
    Text("Step 1")
        .accessibilitySortPriority(2)
}
```

**Correct (proper focus management):**

```swift
// Focus moves to sheet content automatically
.sheet(isPresented: $showSheet) {
    NavigationStack {
        SheetContent()
            .navigationTitle("Title")
    }
}
// SwiftUI handles focus for standard presentations

// Announce and focus new content
@AccessibilityFocusState var isResultFocused: Bool

VStack {
    if showResult {
        Text("Result: Success")
            .accessibilityFocused($isResultFocused)
    }
    Button("Get Result") {
        showResult = true
        isResultFocused = true
    }
}

// Logical grouping
VStack {
    Text("Section Title")
    Text("Section content here")
}
.accessibilityElement(children: .combine)

// Custom focus order when needed
HStack {
    Text("Name: ")
    TextField("", text: $name)
}
.accessibilityElement(children: .contain)
// Groups for logical navigation

// Announce dynamic content changes
Text(statusMessage)
    .accessibilityAddTraits(.updatesFrequently)
    .onChange(of: statusMessage) { _, newValue in
        UIAccessibility.post(notification: .announcement, argument: newValue)
    }
```

**Focus management principles:**
- Let system handle standard presentations
- Move focus to new content (alerts, results)
- Group related elements logically
- Use `.accessibilityFocusState` for dynamic changes
- Announce important updates

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
