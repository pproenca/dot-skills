---
title: Use @Bindable for @Observable Bindings
impact: HIGH
impactDescription: eliminates 100% of compiler errors when binding to @Observable properties in child views — saves 5-15 lines of manual Binding(get:set:) boilerplate per form control and enables 2-way data flow for TextField, Toggle, and Stepper
tags: craft, bindable, observable, kocienda-craft, state, ios17
---

## Use @Bindable for @Observable Bindings

Kocienda's craft means mastering the tools available. `@Observable` gives you property-level tracking, but when a child view receives an `@Observable` object and needs to create `$` bindings to its properties (for `TextField`, `Toggle`, `Stepper`), it needs `@Bindable`. This is the bridge between observation and mutation — without it, the child can read but not write, and form controls cannot function.

**Incorrect (cannot create bindings without @Bindable):**

```swift
@Observable class ProfileEditor {
    var displayName = ""
    var bio = ""
    var isPublic = true
}

struct ProfileFormView: View {
    var editor: ProfileEditor  // Plain property — no $ access

    var body: some View {
        Form {
            TextField("Name", text: $editor.displayName)
            // Compiler error: cannot find '$editor' in scope
        }
    }
}
```

**Correct (@Bindable enables $ binding syntax):**

```swift
@Observable class ProfileEditor {
    var displayName = ""
    var bio = ""
    var isPublic = true
}

struct ProfileFormView: View {
    @Bindable var editor: ProfileEditor

    var body: some View {
        Form {
            TextField("Name", text: $editor.displayName)

            TextField("Bio", text: $editor.bio, axis: .vertical)
                .lineLimit(3...6)

            Toggle("Public Profile", isOn: $editor.isPublic)
        }
    }
}

// Parent owns the state
struct ProfileScreen: View {
    @State private var editor = ProfileEditor()

    var body: some View {
        NavigationStack {
            ProfileFormView(editor: editor)
                .navigationTitle("Edit Profile")
        }
    }
}
```

**When to use each wrapper:**
| Wrapper | Use When |
|---------|----------|
| `@State` | You own the `@Observable` object (create it in this view) |
| `@Bindable` | You receive the object and need `$` bindings |
| `@Environment` | The object is injected via `.environment()` |
| Plain property | You only read the object, never need `$` bindings |

**When NOT to use @Bindable:** If the child only reads properties and never binds to them (no `TextField`, `Toggle`, `Stepper`), pass the object as a plain parameter. `@Bindable` implies write access.

Reference: [Bindable - Apple Documentation](https://developer.apple.com/documentation/swiftui/bindable)
