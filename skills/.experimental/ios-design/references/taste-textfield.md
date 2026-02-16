---
title: Configure Text Input with the Right Keyboard and Content Type
impact: HIGH
impactDescription: wrong keyboard type forces users to switch keyboards manually — correct content type enables autofill for passwords, emails, and addresses, saving 5-15 seconds per field
tags: taste, textfield, keyboard, autofill, kocienda-taste, edson-conviction, input
---

## Configure Text Input with the Right Keyboard and Content Type

Kocienda literally invented the iPhone keyboard — his team spent years ensuring that the right keys appeared for the right context. Email fields show `@` and `.` prominently; number fields show the numeric pad; URL fields show `.com`. Not configuring the keyboard type is wasting the work Kocienda's team did. Edson's conviction means committing to the right input configuration for every field, not leaving it to the default.

**Incorrect (default keyboard for all input types):**

```swift
Form {
    TextField("Email", text: $email)
    // Default keyboard — user must switch to symbols for @

    TextField("Phone", text: $phone)
    // Default keyboard — user types numbers on QWERTY

    SecureField("Password", text: $password)
    // No content type — no autofill, no password manager
}
```

**Correct (configured keyboard, content type, and submit behavior):**

```swift
Form {
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()

    TextField("Phone", text: $phone)
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)

    SecureField("Password", text: $password)
        .textContentType(.password)

    TextField("Street Address", text: $address)
        .textContentType(.streetAddressLine1)
}
.submitLabel(.next)
```

**Keyboard and content type cheat sheet:**
| Field | Keyboard Type | Content Type |
|-------|---------------|-------------|
| Email | `.emailAddress` | `.emailAddress` |
| Password | N/A (SecureField) | `.password` / `.newPassword` |
| Phone | `.phonePad` | `.telephoneNumber` |
| URL | `.URL` | `.URL` |
| Numeric amount | `.decimalPad` | N/A |
| Search | `.default` | N/A |
| Name | `.default` | `.name` / `.givenName` / `.familyName` |
| Address | `.default` | `.streetAddressLine1` |
| Credit card | `.numberPad` | `.creditCardNumber` |

**When NOT to configure:** Free-form text fields (notes, comments, messages) should use the default keyboard with autocorrect enabled. Don't disable autocorrect globally.

Reference: [Text fields - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/text-fields)
