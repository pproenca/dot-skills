---
title: Use @FocusState for Keyboard Navigation in Forms
impact: MEDIUM
impactDescription: enables tab-through form fields, critical for external keyboard users
tags: ally, focus-state, keyboard, forms, tab-order
---

## Use @FocusState for Keyboard Navigation in Forms

Forms presented via sheet or push navigation need `@FocusState` to control which field is active. Without it, the keyboard toolbar shows no Next/Previous buttons, users cannot tab between fields with an external keyboard, and there is no way to programmatically move focus after validation errors. This is critical for iPad users with external keyboards and anyone relying on assistive switch controls.

**Incorrect (no focus management in navigation form):**

```swift
struct CreateAccountView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    // BAD: No keyboard toolbar Next/Previous arrows
                    // External keyboard Tab does nothing
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                Section("Security") {
                    SecureField("Password", text: $password)
                }
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
                Button("Create Account") { validate() }
            }
            .navigationTitle("Sign Up")
        }
    }
    private func validate() {
        if email.isEmpty {
            errorMessage = "Email is required"
            // BAD: No way to move focus to the email field
        }
    }
}
```

**Correct (@FocusState enables keyboard navigation and error focus):**

```swift
@Equatable
struct CreateAccountView: View {
    enum Field: Hashable { case name, email, password }
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                }
                Section("Security") {
                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { validate() }
                }
                if !errorMessage.isEmpty {
                    Section { Text(errorMessage).foregroundColor(.red) }
                }
                Button("Create Account") { validate() }
            }
            .navigationTitle("Sign Up")
            .onAppear { focusedField = .name }
        }
    }
    private func validate() {
        if name.isEmpty { errorMessage = "Name is required"; focusedField = .name }
        else if email.isEmpty || !email.contains("@") { errorMessage = "Valid email is required"; focusedField = .email }
        else if password.count < 8 { errorMessage = "Password >= 8 chars"; focusedField = .password }
        else { errorMessage = ""; focusedField = nil; submitAccount() }
    }
}
```
