---
title: Use TextField with Binding for Text Input
impact: MEDIUM-HIGH
impactDescription: TextField requires @State or @Binding for two-way text updates
tags: input, textfield, binding, state, forms
---

## Use TextField with Binding for Text Input

TextField provides an editable text field that requires a two-way binding to a `@State` or `@Binding` property. Without a binding, there is no way for the user to type into the field and have the value reflected in your view's state. A plain Text view displays content but cannot accept input, which is a common mistake when transitioning from read-only to editable interfaces.

**Incorrect (Text view that cannot accept input):**

```swift
struct NameEntryForm: View {
    @State private var firstName = ""
    @State private var lastName = ""

    var body: some View {
        Form {
            Text(firstName) // displays text but user cannot type into it
            Text(lastName)
            Button("Save") {
                print("Saving \(firstName) \(lastName)")
            }
        }
    }
}
```

**Correct (TextField with $ binding for two-way updates):**

```swift
struct NameEntryForm: View {
    @State private var firstName = ""
    @State private var lastName = ""

    var body: some View {
        Form {
            TextField("First name", text: $firstName) // $ creates a two-way binding
            TextField("Last name", text: $lastName)
            Button("Save") {
                print("Saving \(firstName) \(lastName)")
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
