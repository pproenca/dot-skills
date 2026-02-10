---
title: Minimize Data Entry Friction
impact: MEDIUM
impactDescription: AutoFill with textContentType reduces form completion time by 50-70% — appropriate keyboard types prevent 80%+ of format errors
tags: ux, forms, input, data-entry
---

## Minimize Data Entry Friction

Make data entry as easy as possible: use appropriate keyboards, enable AutoFill, provide defaults, and minimize required fields.

**Incorrect (friction-heavy forms):**

```swift
// All fields required, no help
Form {
    TextField("First Name", text: $firstName)
    TextField("Last Name", text: $lastName)
    TextField("Email", text: $email)
    TextField("Phone", text: $phone)
    TextField("Address Line 1", text: $address1)
    TextField("Address Line 2", text: $address2)
    TextField("City", text: $city)
    TextField("State", text: $state)
    TextField("ZIP", text: $zip)
    TextField("Country", text: $country)
}
// 10 fields, no AutoFill, generic keyboards

// Manual date entry
TextField("Birth Date (MM/DD/YYYY)", text: $birthDate)
// Error-prone format
```

**Correct (friction-minimized input):**

```swift
Form {
    Section("Contact") {
        TextField("Name", text: $name)
            .textContentType(.name)
            .textInputAutocapitalization(.words)

        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)

        TextField("Phone", text: $phone)
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)
    }

    Section("Address") {
        TextField("Street", text: $street)
            .textContentType(.streetAddressLine1)

        TextField("City", text: $city)
            .textContentType(.addressCity)

        // Picker instead of text for state
        Picker("State", selection: $state) {
            ForEach(states, id: \.self) { state in
                Text(state)
            }
        }

        TextField("ZIP", text: $zip)
            .textContentType(.postalCode)
            .keyboardType(.numberPad)
    }
}

// Native date picker
DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)

// Sensible defaults
Toggle("Same as billing address", isOn: $sameAsBilling)
// Pre-fill shipping with billing address
```

**Data entry principles:**
- Use pickers over text fields when options are limited
- Enable AutoFill with textContentType
- Show appropriate keyboard
- Pre-fill from available data
- Mark optional vs required clearly
- Validate inline, not just on submit

Reference: [Entering data - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/entering-data)
