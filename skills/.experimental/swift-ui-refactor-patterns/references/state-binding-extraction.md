---
title: Extract @Binding to Isolate Child Re-renders
impact: CRITICAL
impactDescription: prevents parent re-render from cascading to all children
tags: state, binding, extraction, re-renders, composition
---

## Extract @Binding to Isolate Child Re-renders

When a parent passes an entire model to a child view, the child re-renders on every change to any property of that model, even properties the child never reads. By extracting a @Binding to only the specific field the child edits, you scope its dependency so it re-renders only when that field changes. This is especially important in forms where multiple children each edit one field of a shared model.

**Incorrect (child depends on entire model, re-renders on any change):**

```swift
struct ProfileEditor: View {
    @State private var profile = UserProfile()

    var body: some View {
        Form {
            AvatarPicker(profile: $profile)
            // AvatarPicker re-renders when profile.bio,
            // profile.displayName, or any other field changes
            TextField("Display Name", text: $profile.displayName)
            TextEditor(text: $profile.bio)
        }
    }
}

struct AvatarPicker: View {
    @Binding var profile: UserProfile

    var body: some View {
        Image(profile.avatarName)
            .onTapGesture { profile.avatarName = "avatar_2" }
    }
}
```

**Correct (child depends only on the field it edits):**

```swift
struct ProfileEditor: View {
    @State private var profile = UserProfile()

    var body: some View {
        Form {
            AvatarPicker(avatarName: $profile.avatarName)
            // AvatarPicker only re-renders when avatarName changes
            TextField("Display Name", text: $profile.displayName)
            TextEditor(text: $profile.bio)
        }
    }
}

struct AvatarPicker: View {
    @Binding var avatarName: String

    var body: some View {
        Image(avatarName)
            .onTapGesture { avatarName = "avatar_2" }
    }
}
```

Reference: [Binding](https://developer.apple.com/documentation/swiftui/binding)
