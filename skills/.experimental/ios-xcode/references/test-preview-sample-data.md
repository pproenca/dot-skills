---
title: Use Preview with Sample Data for Visual Testing
impact: MEDIUM
impactDescription: previews with realistic data catch layout issues without running the full app
tags: test, preview, sample-data, layout, visual-testing
---

## Use Preview with Sample Data for Visual Testing

Previews with empty or minimal data hide real-world layout problems like text truncation, long names overflowing, and empty states never being tested. Using realistic sample data in your previews catches these visual issues during development without launching the full app on a simulator.

**Incorrect (preview with minimal data hides layout issues):**

```swift
#Preview {
    ContactList(contacts: [
        Contact(name: "Alice", phone: "555-0100", email: "a@b.com")
    ])
}
```

**Correct (preview with realistic sample data reveals edge cases):**

```swift
extension Contact {
    static let sampleContacts: [Contact] = [
        Contact(name: "Alice Johnson", phone: "555-0100", email: "alice.johnson@example.com"),
        Contact(name: "Dr. Roberto Garcia-Martinez", phone: "+44 20 7946 0958", email: "roberto.garcia-martinez@longcompany.co.uk"),
        Contact(name: "김민준", phone: "010-1234-5678", email: "minjun.kim@example.kr"),
        Contact(name: "Sam", phone: "", email: ""), // tests missing data
    ]
}

#Preview("Contact list with varied data") {
    NavigationStack {
        ContactList(contacts: Contact.sampleContacts) // reveals truncation and empty states
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
