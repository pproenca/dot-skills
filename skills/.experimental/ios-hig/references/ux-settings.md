---
title: Organize Settings Logically
impact: MEDIUM
impactDescription: ungrouped settings increase search time by 3-5× — grouped sections with headers match iOS Settings patterns users already know
tags: ux, settings, preferences, configuration
---

## Organize Settings Logically

Group related settings together and use clear labels. Most users should never need to visit settings - defaults should work well. Avoid burying essential features.

**Incorrect (poor settings organization):**

```swift
// Flat list of unrelated settings
List {
    Toggle("Notifications", isOn: $notifications)
    Toggle("Dark Mode", isOn: $darkMode) // System handles this
    TextField("Username", text: $username) // Not a setting
    Toggle("Auto-play", isOn: $autoPlay)
    Toggle("Sound", isOn: $sound)
    Picker("Language", selection: $language) // System handles this
    Toggle("Analytics", isOn: $analytics)
}

// Essential features hidden in settings
// Main feature only accessible via Settings → Advanced → Enable Feature
```

**Correct (organized settings):**

```swift
List {
    Section {
        NavigationLink {
            AccountSettingsView()
        } label: {
            Label("Account", systemImage: "person.circle")
        }
    }

    Section("Preferences") {
        NavigationLink {
            NotificationSettingsView()
        } label: {
            Label("Notifications", systemImage: "bell")
        }

        NavigationLink {
            AppearanceSettingsView()
        } label: {
            Label("Appearance", systemImage: "paintbrush")
        }
    }

    Section("Content") {
        Toggle("Auto-play Videos", isOn: $autoPlay)
        Toggle("Sound Effects", isOn: $sound)

        Picker("Default Quality", selection: $quality) {
            Text("Auto").tag(Quality.auto)
            Text("High").tag(Quality.high)
            Text("Low").tag(Quality.low)
        }
    }

    Section("Privacy") {
        Toggle("Share Analytics", isOn: $analytics)

        NavigationLink {
            PrivacyPolicyView()
        } label: {
            Text("Privacy Policy")
        }
    }

    Section {
        NavigationLink {
            AboutView()
        } label: {
            Text("About")
        }
    }
}
.navigationTitle("Settings")
```

**Settings principles:**
- Group by category (Account, Privacy, etc.)
- Use sections with headers
- Keep frequently-used settings accessible
- Don't duplicate system settings (Dark Mode, Language)
- Link to system Settings for permissions
- Show current values inline when possible

Reference: [Settings - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/settings)
