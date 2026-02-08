---
title: Use Computed Properties Over Redundant @State
impact: CRITICAL
impactDescription: eliminates state synchronization bugs and stale data
tags: state, computed, derived, synchronization, refactoring
---

## Use Computed Properties Over Redundant @State

When one piece of state is derived from another, storing both as separate @State properties creates a synchronization problem: the derived value can become stale if you forget to update it after every change to the source. A computed property guarantees the derived value is always consistent with its source, eliminating an entire class of bugs.

**Incorrect (redundant state that can fall out of sync):**

```swift
struct RegistrationForm: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var isFormValid: Bool = false

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .onChange(of: name) { _, _ in
                    isFormValid = !name.isEmpty && !email.isEmpty
                }
            TextField("Email", text: $email)
                .onChange(of: email) { _, _ in
                    isFormValid = !name.isEmpty && !email.isEmpty
                }
            Button("Register") { submit() }
                .disabled(!isFormValid)
        }
    }
}
```

**Correct (computed property always reflects current state):**

```swift
struct RegistrationForm: View {
    @State private var name: String = ""
    @State private var email: String = ""

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            Button("Register") { submit() }
                .disabled(!isFormValid)
        }
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
