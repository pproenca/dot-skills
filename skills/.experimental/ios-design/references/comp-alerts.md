---
title: Use Alerts Sparingly for Critical Information
impact: HIGH
impactDescription: prevents alert misuse; alerts reserved for 1-2 critical user decisions
tags: comp, alerts, confirmation, dialogs
---

## Use Alerts Sparingly for Critical Information

Use alerts only for critical information or destructive action confirmations. Alerts interrupt flow and should be rare. For most confirmations, use action sheets or inline UI instead.

**Incorrect (alert overuse):**

```swift
// Alert for minor info
.alert("Success", isPresented: $showSuccess) {
    Button("OK") { }
} message: {
    Text("Your profile was updated")
}
// Use toast or inline confirmation instead

// Alert for non-destructive choices
.alert("Choose Option", isPresented: $showOptions) {
    Button("Option A") { }
    Button("Option B") { }
    Button("Option C") { }
}
// Use action sheet or inline picker
```

**Correct (alerts for critical decisions):**

```swift
// Destructive confirmation
.alert("Delete Photo?", isPresented: $showDeleteConfirm) {
    Button("Delete", role: .destructive) {
        deletePhoto()
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This photo will be permanently deleted.")
}

// Critical error requiring action
.alert("Connection Lost", isPresented: $showConnectionError) {
    Button("Retry") { retry() }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("Unable to save changes. Would you like to retry?")
}

// Unsaved changes warning
.alert("Discard Changes?", isPresented: $showDiscardAlert) {
    Button("Discard", role: .destructive) { dismiss() }
    Button("Keep Editing", role: .cancel) { }
} message: {
    Text("You have unsaved changes that will be lost.")
}

// For non-critical success feedback, use this instead:
.sensoryFeedback(.success, trigger: saveComplete)
// Or a toast/banner
```

**Alert guidelines:**
- Title: Short, clear question or statement
- Message: Explain consequences
- Destructive button: Use `.destructive` role (appears red)
- Maximum 3 buttons
- Cancel button always present for destructive actions

Reference: [Alerts - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/alerts)
