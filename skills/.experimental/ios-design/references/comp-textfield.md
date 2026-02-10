---
title: Choose and Configure Text Input Components
impact: HIGH
impactDescription: prevents poor text entry experience, enables autocomplete and correct keyboard
tags: comp, textfield, texteditor, input, multiline, keyboard
---

## Choose and Configure Text Input Components

TextField is for single-line input. TextEditor is for multi-line content. Always specify `textContentType` and `keyboardType` for text fields to enable AutoFill, show the right keyboard, and improve input accuracy.

**Incorrect (TextField for long content, no content type):**

```swift
// Single line for multi-line content
TextField("Note", text: $note.content)
    // Single line only, truncates long content

// No content type - misses AutoFill
TextField("Email", text: $email)
    .keyboardType(.default) // Shows full keyboard
```

**Correct (TextEditor for multi-line, configured inputs):**

```swift
// Multi-line content
TextEditor(text: $note.content)
    .focused($isFocused)
    .frame(minHeight: 200)
    .scrollContentBackground(.hidden)
    .background(.background.secondary)
    .clipShape(.rect(cornerRadius: 8))

// Properly configured email field
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

// One-time code
TextField("Code", text: $code)
    .textContentType(.oneTimeCode)
    .keyboardType(.numberPad)
```

**TextField with axis for expandable (iOS 16+):**

```swift
TextField("Message", text: $message, axis: .vertical)
    .lineLimit(1...5)  // Expands from 1 to 5 lines
```

**Common content types:**
| Content Type | AutoFill Source | Keyboard |
|--------------|-----------------|----------|
| `.emailAddress` | Saved emails | Email |
| `.telephoneNumber` | Contacts | Phone pad |
| `.password` | Keychain | Default |
| `.oneTimeCode` | SMS | Number |
| `.postalCode` | Addresses | Number |

**Component decision matrix:**

| Content | Component |
|---------|-----------|
| Username, email | TextField |
| Search query | TextField |
| Password | SecureField |
| Notes, comments | TextEditor |
| Bio, description | TextEditor |

Reference: [Human Interface Guidelines - Text Fields](https://developer.apple.com/design/human-interface-guidelines/text-fields)
