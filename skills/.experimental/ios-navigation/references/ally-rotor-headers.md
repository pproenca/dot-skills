---
title: Mark Navigation Section Headers for VoiceOver Rotor
impact: MEDIUM-HIGH
impactDescription: enables O(1) section jumping instead of O(n) linear swiping
tags: ally, voiceover, rotor, headers, trait
---

## Mark Navigation Section Headers for VoiceOver Rotor

VoiceOver's rotor provides a "Headings" mode that lets users jump directly between sections with a single flick. Without `.isHeader` traits, users must swipe through every element sequentially — in a settings screen with 40 items across 6 sections, that is up to 40 swipes to reach the last section versus 6 rotor flicks. This is the difference between usable and unusable for VoiceOver users.

**Incorrect (visual-only headers with no accessibility trait):**

```swift
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                // BAD: Section headers look like headers visually
                // but VoiceOver treats them as plain text.
                // Rotor "Headings" mode finds nothing — user must
                // swipe through all 40+ items linearly.

                Section {
                    NavigationLink("Profile", value: Route.profile)
                    NavigationLink("Email", value: Route.email)
                    NavigationLink("Password", value: Route.password)
                } header: {
                    // .font(.headline) is visual only — VoiceOver
                    // does not infer semantic role from font size.
                    Text("Account").font(.headline)
                }

                Section {
                    NavigationLink("Notifications", value: Route.notifications)
                    NavigationLink("Privacy", value: Route.privacy)
                    NavigationLink("Data Usage", value: Route.dataUsage)
                } header: {
                    Text("Preferences").font(.headline)
                }

                // ... 4 more sections, 30+ more items
            }
        }
    }
}
```

**Correct (headers marked with .isHeader trait for rotor navigation):**

```swift
@Equatable
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                // VoiceOver rotor "Headings" mode now finds these sections.
                // User can flick up/down to jump: Account -> Preferences -> ...
                // Total flicks to reach last section: 5 (not 40).

                Section {
                    NavigationLink("Profile", value: Route.profile)
                    NavigationLink("Email", value: Route.email)
                    NavigationLink("Password", value: Route.password)
                } header: {
                    Text("Account")
                        .font(.headline)
                        // Registers this element in the VoiceOver rotor
                        // under "Headings". Works with built-in List
                        // Section headers and custom header views.
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    NavigationLink("Notifications", value: Route.notifications)
                    NavigationLink("Privacy", value: Route.privacy)
                    NavigationLink("Data Usage", value: Route.dataUsage)
                } header: {
                    Text("Preferences")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                }

                // Apply to ALL section headers consistently.
                // Partial adoption is worse than none — users expect
                // rotor to find ALL sections once they see one.
            }
            .navigationTitle("Settings")
            .navigationDestination(for: Route.self) { route in
                route.destinationView
            }
        }
    }
}
```
