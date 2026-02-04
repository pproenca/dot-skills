---
title: Configure Text Fields with Appropriate Keyboard and Content Types
impact: HIGH
impactDescription: enables autocomplete, validation, and correct keyboard
tags: comp, text-field, input, keyboard
---

## Configure Text Fields with Appropriate Keyboard and Content Types

Always specify `textContentType` and `keyboardType` for text fields. This enables AutoFill, shows the right keyboard, and improves input accuracy.

**Incorrect (generic text field for everything):**

```swift
// No content type - misses AutoFill
TextField("Email", text: $email)

// Wrong keyboard for phone number
TextField("Phone", text: $phone)
    .keyboardType(.default) // Shows full keyboard

// No autocorrection control
TextField("Username", text: $username)
    // Might autocorrect "john_doe" to something wrong
```

**Correct (properly configured inputs):**

```swift
// Email field
TextField("Email", text: $email)
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()

// Phone field
TextField("Phone", text: $phone)
    .textContentType(.telephoneNumber)
    .keyboardType(.phonePad)

// Password field
SecureField("Password", text: $password)
    .textContentType(.password)

// New password (for registration)
SecureField("Create Password", text: $newPassword)
    .textContentType(.newPassword)

// Username
TextField("Username", text: $username)
    .textContentType(.username)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()

// Name fields
TextField("First Name", text: $firstName)
    .textContentType(.givenName)
    .textInputAutocapitalization(.words)

// One-time code
TextField("Code", text: $code)
    .textContentType(.oneTimeCode)
    .keyboardType(.numberPad)
```

**Common content types:**
| Content Type | AutoFill Source | Keyboard |
|--------------|-----------------|----------|
| `.emailAddress` | Saved emails | Email |
| `.telephoneNumber` | Contacts | Phone pad |
| `.password` | Keychain | Default |
| `.oneTimeCode` | SMS | Number |
| `.postalCode` | Addresses | Number |

Reference: [Text fields - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/text-fields)
