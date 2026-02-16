---
title: Manage Focus After Programmatic Navigation Events
impact: MEDIUM-HIGH
impactDescription: prevents VoiceOver users from losing their place after state changes
tags: ally, focus, voiceover, accessibility-focus-state, programmatic
---

## Manage Focus After Programmatic Navigation Events

When a modal is dismissed, a flow completes, or an error appears, VoiceOver focus may land on an unpredictable element — often the first element on screen or the navigation bar. This disorients users who cannot see the screen. Use `@AccessibilityFocusState` to explicitly direct VoiceOver focus to the most relevant element after programmatic navigation changes, such as a success message, error field, or the triggering button.

**Incorrect (no focus management after sheet dismissal):**

```swift
struct ProfileView: View {
    @State private var showEditSheet = false
    @State private var saveConfirmation = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile").font(.largeTitle)
                // BAD: VoiceOver focus lands on nav bar or first element
                // Confirmation message is never announced
                if !saveConfirmation.isEmpty {
                    Text(saveConfirmation).foregroundColor(.green)
                }
                Button("Edit Profile") { showEditSheet = true }
            }
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet { result in
                    saveConfirmation = "Profile saved successfully"
                    showEditSheet = false
                    // BAD: VoiceOver focus is lost
                }
            }
        }
    }
}
```

**Correct (focus directed to confirmation after dismissal):**

```swift
@Equatable
struct ProfileView: View {
    @State private var showEditSheet = false
    @State private var saveConfirmation = ""
    @AccessibilityFocusState private var isConfirmationFocused: Bool
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile").font(.largeTitle)
                if !saveConfirmation.isEmpty {
                    Text(saveConfirmation)
                        .foregroundColor(.green)
                        .accessibilityFocused($isConfirmationFocused)
                }
                Button("Edit Profile") { showEditSheet = true }
            }
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet { result in
                    saveConfirmation = "Profile saved successfully"
                    showEditSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isConfirmationFocused = true
                    }
                }
            }
        }
    }
}

// Enum-based focus for forms with multiple error targets:
@Equatable
struct SignUpView: View {
    enum FocusTarget: Hashable { case emailError, passwordError }
    @AccessibilityFocusState private var focusTarget: FocusTarget?
    var body: some View {
        Form {
            TextField("Email", text: $email)
            if let emailError {
                Text(emailError)
                    .foregroundColor(.red)
                    .accessibilityFocused($focusTarget, equals: .emailError)
            }
            // focusTarget = .emailError
        }
    }
}
```
