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
                    // BAD: No @FocusState binding. Keyboard toolbar
                    // shows no Next/Previous arrows. External keyboard
                    // Tab key does nothing. User must tap each field.
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
                        // BAD: Error shown but user has no idea
                        // which field caused it. No focus redirect.
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Button("Create Account") {
                    validate()
                }
            }
            .navigationTitle("Sign Up")
        }
    }

    private func validate() {
        if email.isEmpty {
            errorMessage = "Email is required"
            // No way to move focus to the email field.
            // User must manually tap the email field.
        }
    }
}
```

**Correct (@FocusState enables keyboard navigation and error focus):**

```swift
struct CreateAccountView: View {
    // Enum defines the tab order for form fields.
    // Add cases in the order users should navigate.
    enum Field: Hashable {
        case name, email, password
    }

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    // @FocusState tracks which field currently has keyboard focus.
    // Setting it programmatically moves focus (and VoiceOver cursor).
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $name)
                        // Bind to @FocusState. Keyboard toolbar now shows
                        // Next/Previous arrows to move between fields.
                        .focused($focusedField, equals: .name)
                        // Submit label changes Return key to "Next".
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
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
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Button("Create Account") {
                    validate()
                }
            }
            .navigationTitle("Sign Up")
            // Auto-focus the first field when the form appears.
            // User can start typing immediately without tapping.
            .onAppear { focusedField = .name }
        }
    }

    private func validate() {
        if name.isEmpty {
            errorMessage = "Name is required"
            // Programmatically move focus to the error field.
            // Keyboard opens on it, VoiceOver announces it.
            focusedField = .name
        } else if email.isEmpty || !email.contains("@") {
            errorMessage = "Valid email is required"
            // Focus jumps directly to email field — user can
            // fix the error immediately without tapping.
            focusedField = .email
        } else if password.count < 8 {
            errorMessage = "Password must be at least 8 characters"
            focusedField = .password
        } else {
            errorMessage = ""
            // Dismiss keyboard on successful validation.
            focusedField = nil
            submitAccount()
        }
    }
}
```
