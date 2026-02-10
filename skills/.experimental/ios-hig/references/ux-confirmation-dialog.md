---
title: Use Confirmation Dialogs for Destructive Actions
impact: HIGH
impactDescription: prevents accidental data loss — 15-30% of delete taps are unintentional without confirmation
tags: ux, confirmation, destructive, dialog, delete
---

## Use Confirmation Dialogs for Destructive Actions

Use `.confirmationDialog` (action sheet) for destructive actions that can't be undone. Alerts are for important information; confirmation dialogs are for choosing between actions. Never delete data without confirmation.

**Incorrect (immediate destructive action or alert misuse):**

```swift
// No confirmation before permanent delete
Button("Delete Account", role: .destructive) {
    deleteAccount() // gone forever, no warning
}

// Alert used instead of confirmation dialog
.alert("Delete?", isPresented: $showDelete) {
    Button("Delete", role: .destructive) { delete() }
    Button("Cancel", role: .cancel) { }
}
// Alerts are for information, not action selection
```

**Correct (confirmation dialog for destructive actions):**

```swift
Button("Delete Account", role: .destructive) {
    showDeleteConfirmation = true
}
.confirmationDialog(
    "Delete Account",
    isPresented: $showDeleteConfirmation,
    titleVisibility: .visible
) {
    Button("Delete Account", role: .destructive) {
        deleteAccount()
    }
} message: {
    Text("This will permanently delete your account and all data. This cannot be undone.")
}

// Multiple destructive options
.confirmationDialog("Photo", isPresented: $showPhotoOptions) {
    Button("Take Photo") { openCamera() }
    Button("Choose from Library") { openLibrary() }
    Button("Delete Photo", role: .destructive) { deletePhoto() }
}
```

**When to use each:**
| Control | Usage |
|---------|-------|
| `.confirmationDialog` | Choosing between actions, destructive confirmation |
| `.alert` | Important information, simple yes/no decisions |
| Inline undo | Reversible actions (archive, mark as read) |

Reference: [Alerts - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/alerts)
