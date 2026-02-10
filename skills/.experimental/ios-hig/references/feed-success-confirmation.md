---
title: Confirm Successful Actions Appropriately
impact: MEDIUM
impactDescription: missing confirmation causes 20-30% of users to repeat the action — over-confirmation (alerts for minor actions) adds 2-3 unnecessary taps per task
tags: feed, success, confirmation, status
---

## Confirm Successful Actions Appropriately

Confirm successful actions at the right level of prominence. Minor actions need subtle feedback; major actions may warrant more prominent confirmation.

**Incorrect (wrong confirmation level):**

```swift
// Alert for minor action
Button("Add to Favorites") {
    addToFavorites()
}
.alert("Added!", isPresented: $showSuccess) {
    Button("OK") { }
}
// Too prominent for simple action

// No confirmation for important action
Button("Transfer $500") {
    await transfer()
    // Nothing - user wonders if it worked
}

// Blocking confirmation for quick actions
Button("Like") {
    like()
}
.sheet(isPresented: $showConfirmation) {
    Text("You liked this post!")
    Button("Great!") { }
}
// Ridiculous for a like button
```

**Correct (proportional confirmation):**

```swift
// Subtle feedback for minor actions
Button {
    isFavorite.toggle()
} label: {
    Image(systemName: isFavorite ? "heart.fill" : "heart")
        .foregroundColor(isFavorite ? .red : .secondary)
}
.sensoryFeedback(.success, trigger: isFavorite)
// Visual change + haptic is enough

// Toast/banner for moderate actions
Button("Save") {
    await save()
    savedMessage = "Changes saved"
}
// Show brief banner that auto-dismisses

// Full confirmation for significant actions
Button("Complete Purchase") {
    await purchase()
}
// Navigate to confirmation screen with:
// - Order summary
// - Confirmation number
// - Next steps

// Inline success state
HStack {
    TextField("Email", text: $email)
    if isValid {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
    }
}
```

**Confirmation hierarchy:**
| Action | Feedback |
|--------|----------|
| Toggle, like | Animation + haptic |
| Save, update | Brief toast |
| Delete | Confirmation first, then toast |
| Purchase, transfer | Confirmation screen |
| Account change | Email + in-app confirmation |

Reference: [Feedback - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/feedback)
