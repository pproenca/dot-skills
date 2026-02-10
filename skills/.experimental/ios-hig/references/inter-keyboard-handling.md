---
title: Handle Keyboard Appearance Gracefully
impact: HIGH
impactDescription: obscured input fields cause 30-50% of users to dismiss and retry — ScrollView/Form handle keyboard avoidance automatically in 0 extra lines
tags: inter, keyboard, input, scroll
---

## Handle Keyboard Appearance Gracefully

Ensure the keyboard never obscures the active input field. Use keyboard avoidance, scroll into view, or adjust content insets automatically.

**Incorrect (keyboard obscures input):**

```swift
// Fixed layout doesn't move
VStack {
    Spacer()
    TextField("Message", text: $message)
    Button("Send") { }
}
// Input field hidden when keyboard appears

// Manual padding that doesn't adapt
VStack {
    TextField("Email", text: $email)
    TextField("Password", text: $password)
    Button("Login") { }
}
.padding(.bottom, 300) // Hardcoded, wrong on different keyboards
```

**Correct (proper keyboard handling):**

```swift
// ScrollView automatically adjusts
ScrollView {
    VStack(spacing: 16) {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)

        SecureField("Password", text: $password)
            .textContentType(.password)

        Button("Login") { login() }
            .buttonStyle(.borderedProminent)
    }
    .padding()
}
// ScrollView adjusts contentInset for keyboard

// Form handles keyboard automatically
Form {
    Section("Account") {
        TextField("Email", text: $email)
        SecureField("Password", text: $password)
    }
}

// For fixed bottom input (chat-style)
VStack {
    ScrollView {
        // Message list
    }

    HStack {
        TextField("Message", text: $message)
        Button("Send") { }
    }
    .padding()
}
.safeAreaInset(edge: .bottom) {
    // Already handles keyboard
}

```

**Dismiss keyboard with @FocusState:**

```swift
@FocusState private var isFocused: Bool

TextField("Message", text: $message)
    .focused($isFocused)

Button("Done") { isFocused = false }

// Or dismiss on scroll
.scrollDismissesKeyboard(.interactively)
```

**Keyboard handling patterns:**
- ScrollView/Form: Automatic adjustment
- Fixed input: Use `.safeAreaInset`
- Dismiss: `.scrollDismissesKeyboard(.interactively)`
- Focus management: `@FocusState`

Reference: [Keyboards - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/keyboards)
