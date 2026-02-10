---
title: Use @Bindable for Two-Way Model Binding
impact: MEDIUM
impactDescription: enables direct form editing of model properties without manual state sync
tags: state, bindable, binding, swiftdata, forms
---

## Use @Bindable for Two-Way Model Binding

`@Bindable` creates two-way bindings to `@Model` properties, enabling direct editing in `TextField`, `Picker`, `DatePicker`, and other SwiftUI controls. Without it, you must create separate `@State` variables, copy values in `onAppear`, and sync changes back in `onDisappear` — a pattern that is error-prone and can lose edits if the view is dismissed unexpectedly.

**Incorrect (manual state sync — stale data risk and lost edits):**

```swift
struct FriendEditor: View {
    var friend: Friend
    @State private var name = ""
    @State private var birthday = Date.now

    var body: some View {
        Form {
            TextField("Name", text: $name)
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
        }
        .onAppear {
            name = friend.name
            birthday = friend.birthday
        }
        .onDisappear {
            // If the app crashes here, edits are lost
            friend.name = name
            friend.birthday = birthday
        }
    }
}
```

**Correct (@Bindable for direct model binding — changes tracked automatically):**

```swift
struct FriendEditor: View {
    @Bindable var friend: Friend

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
            DatePicker("Birthday", selection: $friend.birthday, displayedComponents: .date)
        }
    }
}
```

**Benefits:**
- Changes are written directly to the model — no sync code needed
- SwiftData's autosave persists edits automatically
- The view always displays the current model state, never a stale copy

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
