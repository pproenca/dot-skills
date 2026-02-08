---
title: Use Action Sheets for Contextual Choices
impact: MEDIUM-HIGH
impactDescription: presents choices in context without full screen interruption
tags: comp, action-sheet, choices, context-menu
---

## Use Action Sheets for Contextual Choices

Use action sheets (confirmation dialogs) to present a set of choices related to an action. They slide up from the bottom on iPhone and appear as popovers on iPad.

**Incorrect (wrong UI for choices):**

```swift
// Alert for multiple options
.alert("Options", isPresented: $showOptions) {
    Button("Share") { }
    Button("Edit") { }
    Button("Duplicate") { }
    Button("Delete") { }
    Button("Cancel", role: .cancel) { }
}
// Alerts shouldn't have many choices

// Full sheet for simple options
.sheet(isPresented: $showOptions) {
    List {
        Button("Share") { }
        Button("Edit") { }
    }
}
// Overkill for quick choices
```

**Correct (action sheet for choices):**

```swift
.confirmationDialog(
    "Photo Options",
    isPresented: $showPhotoOptions,
    titleVisibility: .visible
) {
    Button("Share") { sharePhoto() }
    Button("Edit") { editPhoto() }
    Button("Duplicate") { duplicatePhoto() }
    Button("Delete", role: .destructive) { deletePhoto() }
    Button("Cancel", role: .cancel) { }
}

// Triggered from button or long press
Button("More") {
    showPhotoOptions = true
}

// Or from context menu (better for discovery)
.contextMenu {
    Button("Share", systemImage: "square.and.arrow.up") { }
    Button("Edit", systemImage: "pencil") { }
    Divider()
    Button("Delete", systemImage: "trash", role: .destructive) { }
}
```

**Action sheet guidelines:**
- Destructive actions at top, in red
- Cancel button at bottom (always include)
- Keep title short or omit
- Maximum ~7 options before scrolling
- Use context menu for in-place actions

Reference: [Action sheets - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/action-sheets)
