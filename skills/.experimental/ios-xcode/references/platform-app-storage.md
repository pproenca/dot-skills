---
title: Use AppStorage for User Preferences
impact: MEDIUM
impactDescription: automatic persistence and SwiftUI integration
tags: platform, appstorage, userdefaults, preferences, persistence
---

## Use AppStorage for User Preferences

@AppStorage wraps UserDefaults with SwiftUI reactivity. Changes persist automatically and trigger view updates.

**Incorrect (manual UserDefaults):**

```swift
struct SettingsView: View {
    @State private var darkModeEnabled: Bool

    init() {
        _darkModeEnabled = State(initialValue: UserDefaults.standard.bool(forKey: "darkMode"))
    }

    var body: some View {
        Toggle("Dark Mode", isOn: $darkModeEnabled)
            .onChange(of: darkModeEnabled) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "darkMode")  // Manual sync
            }
    }
}
```

**Correct (AppStorage):**

```swift
struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        Toggle("Dark Mode", isOn: $darkModeEnabled)
        // Automatically persisted to UserDefaults
    }
}
```

**Supported types:**

```swift
@AppStorage("username") var username = ""           // String
@AppStorage("itemCount") var itemCount = 0          // Int
@AppStorage("price") var price = 0.0                // Double
@AppStorage("isEnabled") var isEnabled = false      // Bool
@AppStorage("selectedTab") var selectedTab: Tab = .home  // RawRepresentable
@AppStorage("lastOpened") var lastOpened: Date?     // Optional with nil default
```

**Custom app group for sharing:**

```swift
// Share between app and widget
@AppStorage("streak", store: UserDefaults(suiteName: "group.com.app.shared"))
var streak = 0
```

**Enum storage with RawRepresentable:**

```swift
enum Theme: String, CaseIterable {
    case system, light, dark
}

struct AppearanceSettings: View {
    @AppStorage("theme") private var theme: Theme = .system

    var body: some View {
        Picker("Theme", selection: $theme) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Text(theme.rawValue.capitalized)
            }
        }
    }
}
```

**When NOT to use AppStorage:**
- Large data (use FileManager or Core Data)
- Sensitive data (use Keychain)
- Complex objects (use Codable + file storage)

Reference: [AppStorage Documentation](https://developer.apple.com/documentation/swiftui/appstorage)
