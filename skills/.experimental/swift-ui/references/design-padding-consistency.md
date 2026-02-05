---
title: Apply Consistent Padding Patterns
impact: CRITICAL
impactDescription: creates visual rhythm and professional polish
tags: design, padding, consistency, layout, spacing
---

## Apply Consistent Padding Patterns

Inconsistent padding creates visual noise. Use the same padding values for the same contexts throughout your app.

**Incorrect (inconsistent padding):**

```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                Text("Email")
                    .padding(.horizontal, 16)  // 16pt
                Text("Password")
                    .padding(.horizontal, 20)  // Different: 20pt
            }

            Section("Preferences") {
                Text("Notifications")
                    .padding(.leading, 12)  // Different: 12pt
            }
        }
    }
}
```

**Correct (systematic padding):**

```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                SettingsRow(title: "Email", value: user.email)
                SettingsRow(title: "Password", value: "••••••••")
            }

            Section("Preferences") {
                SettingsRow(title: "Notifications", value: "On")
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        // List provides consistent padding automatically
    }
}
```

**Padding guidelines:**

```swift
// Screen-level content padding
.padding(.horizontal, 16)  // Standard iOS margin

// Card/grouped content
.padding(16)  // Equal padding all sides

// Compact elements (buttons, chips)
.padding(.horizontal, 12)
.padding(.vertical, 8)

// Touch targets (minimum 44pt)
.frame(minHeight: 44)
```

**Use SwiftUI's built-in spacing:**

```swift
List { }           // Automatic row padding
Form { }           // Automatic form padding
NavigationStack { } // Automatic navigation padding
```

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
