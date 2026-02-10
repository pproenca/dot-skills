---
title: "Configure Stack Alignment and Spacing"
impact: CRITICAL
impactDescription: "controls alignment and spacing for 90%+ of SwiftUI layouts"
tags: layout, stacks, alignment, spacing, forms
---

## Configure Stack Alignment and Spacing

VStack defaults to center alignment and system-standard spacing, which almost never matches design specifications for form-like layouts. Labels and fields end up centered instead of left-aligned, and the vertical rhythm feels off. Explicitly setting alignment and spacing ensures the layout matches the design from the start and stays consistent across platforms.

**Incorrect (default centering misaligns form labels and fields):**

```swift
struct ContactFormView: View {
    @State private var fullName = ""
    @State private var emailAddress = ""
    @State private var phoneNumber = ""

    var body: some View {
        VStack { // defaults to .center alignment and system spacing
            Text("Contact Information")
                .font(.title2)
            Text("Full Name")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your name", text: $fullName)
                .textFieldStyle(.roundedBorder)
            Text("Email Address")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your email", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
            Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your phone", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
```

**Correct (explicit alignment and spacing match design specs):**

```swift
struct ContactFormView: View {
    @State private var fullName = ""
    @State private var emailAddress = ""
    @State private var phoneNumber = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // left-aligned with consistent rhythm
            Text("Contact Information")
                .font(.title2)
                .padding(.bottom, 4)
            Text("Full Name")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your name", text: $fullName)
                .textFieldStyle(.roundedBorder)
            Text("Email Address")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your email", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
            Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your phone", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
