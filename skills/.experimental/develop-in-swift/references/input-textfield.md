---
title: Use TextField with Binding for Text Input
impact: HIGH
impactDescription: captures user text, two-way binding updates state, keyboard management
tags: input, swiftui, textfield, input, binding, forms
---

## Use TextField with Binding for Text Input

`TextField` captures single-line text input. It requires a binding (`$`) to a String state property. The view updates as the user types.

**Incorrect (no binding):**

```swift
// TextField needs a binding, not a plain value
struct SearchView: View {
    var searchText = ""  // Not @State

    var body: some View {
        TextField("Search", text: searchText)  // Error: needs Binding<String>
    }
}
```

**Correct (TextField with binding):**

```swift
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)
    }
}

// With prompt (iOS 15+)
TextField("Name", text: $name, prompt: Text("Enter your name"))

// Styled TextField
TextField("Email", text: $email)
    .textFieldStyle(.roundedBorder)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .autocapitalization(.none)

// In a Form
Form {
    TextField("Name", text: $name)
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
}

// Secure text entry
SecureField("Password", text: $password)

// Multi-line text
TextEditor(text: $notes)
    .frame(height: 100)
```

**TextField options:**
- `.keyboardType()` - email, number, URL, etc.
- `.textContentType()` - enables autofill
- `.autocapitalization()` - control capitalization
- `SecureField` for passwords
- `TextEditor` for multi-line

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)
