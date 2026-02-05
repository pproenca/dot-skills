---
title: Use Button with Action Closures
impact: HIGH
impactDescription: primary interaction element, closure-based actions, proper styling
tags: input, swiftui, button, actions, closures, interaction
---

## Use Button with Action Closures

`Button` triggers actions when tapped. The action is a closure that runs on tap. Use trailing closure syntax for clean code. Apply button styles for different visual treatments.

**Incorrect (wrong closure syntax):**

```swift
// Don't call function immediately
Button("Save", action: saveData())  // Wrong: calls saveData immediately

// Don't use NavigationLink for actions
NavigationLink("Delete") {
    // Wrong: NavigationLink is for navigation, not actions
}
```

**Correct (Button with closure):**

```swift
// Basic button with trailing closure
Button("Add Friend") {
    addNewFriend()
}

// Button with label
Button {
    count += 1
} label: {
    Text("Increment")
}

// Button with image and text
Button {
    saveChanges()
} label: {
    Label("Save", systemImage: "square.and.arrow.down")
}

// Button styles
Button("Primary Action") {
    performAction()
}
.buttonStyle(.borderedProminent)

Button("Secondary") {
    cancel()
}
.buttonStyle(.bordered)

// Destructive button
Button("Delete", role: .destructive) {
    deleteItem()
}

// Disabled button
Button("Submit") {
    submit()
}
.disabled(formIsInvalid)
```

**Button styles:**
- `.automatic` - Platform default
- `.bordered` - Light background
- `.borderedProminent` - Tinted background
- `.plain` - No visual treatment
- Use `role: .destructive` for delete actions

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)
